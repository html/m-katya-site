(in-package :m-katya-site)

(defwidget callback-selector-widget (on-demand-selector)
  ())

(defmethod update-children ((selector callback-selector-widget))
  (declare (special *uri-tokens*))
  (setf (selector-base-uri selector)
	(make-webapp-uri
	 (string-left-trim
	  "/" (string-right-trim
	       "/" (uri-tokens-to-string (consumed-tokens *uri-tokens*))))))
  (let ((widget (get-widget-for-tokens selector *uri-tokens*)))
    ;(error (format nil "~A~%" (remaining-tokens  *uri-tokens*)))
    (if widget
      (setf (widget-children selector :selector) widget)
      (if (remaining-tokens *uri-tokens*)
        (assert (signal 'http-not-found))
        #'init-user-session))))
