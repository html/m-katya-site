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

(defun shop-item-big-image-dimensions-string ()
  (format nil "~Ax~A" (car *shop-item-big-image-dimensions*) (cdr *shop-item-big-image-dimensions*)))

(defun shop-item-thumbnail-image-dimensions-string ()
  (format nil "~Ax~A" (car *shop-item-thumbnail-image-dimensions*) (cdr *shop-item-thumbnail-image-dimensions*)))

(defun get-thumbnail-images-directory-for-shop-item ()
  (merge-pathnames 
    (make-pathname :directory `(:relative 
                                 ,(format nil "generated/~A" (shop-item-thumbnail-image-dimensions-string))))
    (compute-webapp-public-files-path (weblocks:get-webapp 'm-katya-site))))

(defun get-big-images-directory-for-shop-item ()
  (merge-pathnames 
    (make-pathname :directory `(:relative 
                                 ,(format nil "generated/~A" (shop-item-big-image-dimensions-string))))
    (compute-webapp-public-files-path (weblocks:get-webapp 'm-katya-site))))


(defmethod remove-file ((obj shop-item) file-name)
  (with-slots (files) obj
    (when (find file-name files :test #'string=)
      (let  ((file-names (list 
                      (merge-pathnames file-name 
                                       (get-upload-directory))
                      (merge-pathnames file-name 
                                       (get-thumbnail-images-directory-for-shop-item))
                      (merge-pathnames file-name 
                                       (get-big-images-directory-for-shop-item)))))
        (loop for i in file-names do 
              (when (probe-file i)
                (delete-file i))))
      (setf files (remove file-name files :test #'string=)))))
