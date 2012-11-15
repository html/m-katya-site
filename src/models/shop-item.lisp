(in-package :m-katya-site)

(defclass shop-item ()
  ((id)
   (title :accessor shop-item-title :initarg :title)
   (price :type integer :accessor shop-item-price :initarg :price)
   (files :initform nil)))
