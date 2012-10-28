(in-package :m-katya-site)


(defclass page ()
  ((id)
   (title :accessor page-title :initarg :title)
   (name :initarg :name)
   (content :accessor page-content :initarg :content)))
