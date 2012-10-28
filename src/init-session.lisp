(in-package :m-katya-site)

;; Define callback function to initialize new sessions
(defun init-user-session (comp)
  (setf (composite-widgets comp)
  (list 
    (make-instance 'gridedit)
    (lambda (&rest args)
    (with-html
      (:strong "Happy Hacking!"))))))
