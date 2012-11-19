(in-package :m-katya-site)

(defvar *shop-item-thumbnail-image-dimensions* (cons 99 99))
(defvar *shop-item-big-image-dimensions* (cons 450 400))

(defclass shop-item ()
  ((id)
   (title :accessor shop-item-title :initarg :title)
   (price :type integer :accessor shop-item-price :initarg :price)
   (files :initform nil)
   (description :initform nil :accessor shop-item-description)
   (category-title :initform nil :accessor shop-item-category-title)))

(defun list-shop-items-categories ()
  (let ((categories nil))
    (loop for i in (all-of 'shop-item) 
          if (shop-item-category-title i)
          do 
          (pushnew (shop-item-category-title i) categories :test #'string=))
    categories))

(defun shop-items-by-category (category)
  (find-by-values 'shop-item :category-title category))

(defmethod shop-item-list-thumbnail ((item shop-item))
  (with-slots (files) item 
    (collection-small-image (first files))))

(defun shop-item-url (i)
  (format nil "/shop/~A/~A" (url-encode (shop-item-category-title i)) (object-id i)))
