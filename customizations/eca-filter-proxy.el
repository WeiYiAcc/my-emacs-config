;;; eca-filter-proxy.el --- Emacs-native HTTP proxy for ECA -*- lexical-binding: t; -*-

;;; Commentary:
;; kiro-rs 不支持 Anthropic 的 web_search_20250305 内置 tool。
;; 这个 Emacs 内置 proxy 在 eca 发请求前过滤掉不支持的 tool。
;; M-x eca 时通过 eca-before-initialize-hook 自动启动。

;;; Code:

(require 'json)

(defvar eca-filter-proxy-port 18900 "Local proxy port.")
(defvar eca-filter-proxy-upstream "http://104.168.22.124:3001/proxy/claude-all" "Upstream URL.")
(defvar eca-filter-proxy--server nil "Server process.")

(defvar eca-filter-proxy--fake-models
  (json-encode '((data . [((id . "claude-sonnet-4-6") (object . "model"))
                           ((id . "claude-opus-4-6") (object . "model"))])
                  (object . "list")))
  "Fake /v1/models response.")

(defun eca-filter-proxy--log (fmt &rest args)
  "Log proxy message with FMT and ARGS."
  (apply #'message (concat "[eca-proxy] " fmt) args))

(defun eca-filter-proxy--send-response (proc status content-type body)
  "Send HTTP response to PROC with STATUS, CONTENT-TYPE, BODY."
  (let ((resp (format "HTTP/1.1 %s\r\nContent-Type: %s\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s"
                      status content-type (string-bytes body) body)))
    (process-send-string proc resp)
    (delete-process proc)))

(defun eca-filter-proxy--forward-post (proc path body)
  "Forward POST to upstream PATH with BODY, send response to PROC."
  (let* ((url-request-method "POST")
         (url-request-extra-headers
          `(("Content-Type" . "application/json")
            ("anthropic-version" . "2023-06-01")
            ("x-api-key" . ,(let ((cfg (json-read-file (expand-file-name "~/.config/eca/config.json"))))
                             (alist-get 'key (alist-get 'anthropic (alist-get 'providers cfg)))))))
         (url-request-data (encode-coding-string body 'utf-8))
         (url (concat eca-filter-proxy-upstream path)))
    (url-retrieve url
                  (lambda (status)
                    (unwind-protect
                        (if (plist-get status :error)
                            (eca-filter-proxy--send-response proc "502 Bad Gateway" "application/json"
                                                            "{\"error\":\"upstream failed\"}")
                          (goto-char (point-min))
                          (when (re-search-forward "\n\n" nil t)
                            (let ((resp-body (buffer-substring-no-properties (point) (point-max))))
                              (eca-filter-proxy--send-response proc "200 OK" "application/json" resp-body))))
                      (kill-buffer)))
                  nil t t)))

(defun eca-filter-proxy--handle-client (proc)
  "Handle complete request from client PROC."
  (let* ((data (process-get proc :data))
         (header-end (string-match "\r\n\r\n" data))
         (headers (substring data 0 header-end))
         (body (substring data (+ header-end 4)))
         (request-line (car (split-string headers "\r\n")))
         (method (car (split-string request-line " ")))
         (path (cadr (split-string request-line " "))))
    (cond
     ;; GET /v1/models
     ((and (string= method "GET") (string-match-p "models" path))
      (eca-filter-proxy--send-response proc "200 OK" "application/json"
                                       eca-filter-proxy--fake-models))
     ;; POST /v1/messages
     ((string= method "POST")
      (let* ((json-object-type 'alist)
             (json-array-type 'vector)
             (parsed (condition-case nil (json-read-from-string body) (error nil))))
        (when parsed
          (let ((tools (alist-get 'tools parsed)))
            (when tools
              (let* ((filtered (seq-filter (lambda (t) (alist-get 'input_schema t))
                                          (append tools nil)))
                     (removed (- (length tools) (length filtered))))
                (when (> removed 0)
                  (eca-filter-proxy--log "filtered %d non-standard tools" removed))
                (setf (alist-get 'tools parsed) (vconcat filtered)))))
          (setq body (json-encode parsed))))
      (eca-filter-proxy--forward-post proc path body))
     ;; Other
     (t (eca-filter-proxy--send-response proc "404 Not Found" "text/plain" "not found")))))

(defun eca-filter-proxy--client-filter (proc string)
  "Accumulate STRING from client PROC, handle when complete."
  (process-put proc :data (concat (or (process-get proc :data) "") string))
  (let ((data (process-get proc :data)))
    (when-let* ((header-end (string-match "\r\n\r\n" data)))
      (let ((content-length
             (when (string-match "Content-Length: \\([0-9]+\\)" data)
               (string-to-number (match-string 1 data)))))
        (when (or (not content-length)
                  (>= (- (length data) (+ header-end 4)) content-length))
          (eca-filter-proxy--handle-client proc))))))

(defun eca-filter-proxy--sentinel (proc event)
  "Handle server PROC EVENT."
  (when (and (string-match-p "open" event)
             (not (eq proc eca-filter-proxy--server)))
    ;; New client connection
    (set-process-filter proc #'eca-filter-proxy--client-filter)
    (process-put proc :data "")))

;;;###autoload
(defun eca-filter-proxy-start ()
  "Start the ECA filter proxy."
  (interactive)
  (when (and eca-filter-proxy--server (process-live-p eca-filter-proxy--server))
    (eca-filter-proxy--log "already running on port %d" eca-filter-proxy-port)
    (cl-return-from eca-filter-proxy-start nil))
  (setq eca-filter-proxy--server
        (make-network-process
         :name "eca-filter-proxy"
         :server t
         :host "127.0.0.1"
         :service eca-filter-proxy-port
         :family 'ipv4
         :sentinel #'eca-filter-proxy--sentinel
         :coding 'binary
         :noquery t))
  (eca-filter-proxy--log "started on 127.0.0.1:%d" eca-filter-proxy-port))

;;;###autoload
(defun eca-filter-proxy-stop ()
  "Stop the ECA filter proxy."
  (interactive)
  (when eca-filter-proxy--server
    (delete-process eca-filter-proxy--server)
    (setq eca-filter-proxy--server nil)
    (eca-filter-proxy--log "stopped")))

;; Auto-start when eca initializes
(add-hook 'eca-before-initialize-hook #'eca-filter-proxy-start)

(provide 'eca-filter-proxy)
;;; eca-filter-proxy.el ends here
