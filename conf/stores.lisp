(in-package :m-katya-site)

;;; Multiple stores may be defined. The last defined store will be the
;;; default.
(defstore *m-katya-site-store* :prevalence
  (merge-pathnames (make-pathname :directory '(:relative "data"))
       (asdf-system-directory :m-katya-site)))
