(in-package :cl-user)

(defun object->simple-plist (object &rest filters)
  (loop for i in (sb-mop:class-direct-slots (find-class (class-name  (class-of object)))) append 
        (let* ((slot (intern (string (sb-mop:slot-definition-name i)) "KEYWORD"))
               (value (if (slot-boundp object (sb-mop:slot-definition-name i))
                        (slot-value object (sb-mop:slot-definition-name i))
                        "Unbound")))
          (list slot (if (getf filters slot) (funcall (getf filters slot) value) value)))))

(require :prevalence-serialized-i18n)
(prevalence-serialized-i18n::load-data 
  "i18n-data/weblocks-filtering-widget-russian-translation-data.serialized"
  "i18n-data/weblocks-russian-translation-data.serialized")

;(print (mapcar #'object->simple-plist prevalence-serialized-i18n::*translations*))
;(print (mapcar #'object->simple-plist prevalence-serialized-i18n::*translation-strings*))
(with-open-file (debug "debug.txt" :direction :output :if-does-not-exist :create :if-exists :supersede)
  (format debug ""))

(export '(*potential-strings-to-translate* *translation-function*))
(defvar *potential-strings-to-translate* nil)
(defvar *standard-double-quote-writer* (get-macro-character #\"))
(defvar *packages-to-translate* (list :m-katya-site :weblocks :weblocks-filtering-widget :weblocks-twitter-bootstrap-application))
(defvar *packages-used* nil)
(defvar *translation-function* #'prevalence-serialized-i18n::translate)

(defun translate (string)
  (let ((translated-value (funcall *translation-function* string :package (intern (package-name *package*) "KEYWORD"))))
    (with-open-file (debug "debug.txt" :direction :output :if-exists :append)
      (format debug "~A ~A ~A ~A~%" string *package* translated-value (equal *translation-function* #'prevalence-serialized-i18n::translate)))
    translated-value))

(defun globalization-double-quote-reader (stream macro-char)
  (declare (ignore macro-char))
  (flet ((copy-string-until-double-quote 
           (stream out)
           (loop for char = (read-char stream t nil t)
                 while (char/= char #\")
                 do (write-char
                      (cond ((char= char #\\)
                             (let ((next-char (read-char stream t nil t)))
                               (case next-char
                                 (#\t #\Tab)
                                 (#\n #\Newline)
                                 (otherwise next-char))))
                            (t char))
                      out)))
         (package-is-needed-for-translation-p 
           ()
           (find (intern (package-name *package*) "KEYWORD") *packages-to-translate*))
         (package-is-pushed-as-used 
           ()
           (find (package-name *package*) *packages-used* :test #'string=)))

    (let ((out-string))
      (with-output-to-string (out)
        (copy-string-until-double-quote stream out)
        (setf out-string (get-output-stream-string out)))

      (when (string= out-string "Email")
        (error (package-name *package*)))

      (when (not (package-is-needed-for-translation-p))
        (return-from globalization-double-quote-reader out-string))


      (unless (package-is-pushed-as-used)
        (push (package-name *package*) *packages-used*))

      (pushnew out-string *potential-strings-to-translate* :test #'string=)

      ;`(,(intern "TRANSLATE" "WEBLOCKS-STRINGS-TRANSLATION-APP") ,out-string)

      (translate out-string))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (set-macro-character #\" 'globalization-double-quote-reader))

; This could be test
(with-output-to-string (out)
  (let ((*standard-output* out))
    (print "test") 
    (print '("test")))) 
