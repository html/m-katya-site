(in-package :m-katya-site)

(defun chunk-list (list size)
  (assert (> size 0))
  (let ((list (copy-list list)))
    (loop while list 
          collect 
          (loop for i from 1 to size while list collect (pop list)))))

(defun url-encode (string)
  (drakma:url-encode string :utf-8))

(defun strip-tags (string)
  (cl-ppcre:regex-replace-all "<[^>]*>" string ""))

(yaclml::def-simple-xtag <:a)

(defmacro capture-weblocks-output (&body body)
  `(let ((*weblocks-output-stream* (make-string-output-stream)))
     ,@body 
     (get-output-stream-string *weblocks-output-stream*)))
