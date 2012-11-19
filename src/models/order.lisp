(in-package :m-katya-site)

(defclass order ()
  ((id)
   (items :initarg :items :accessor order-items)
   (notes :initform nil)
   (completed :initform nil)
   (order-id :initform nil :initarg :order-id)))

(defun generate-unique-order-id ()
  (loop do 
        (let ((new-id (random 10000000)))
          (when (not (first-by-values 'order :order-id new-id))
            (return-from generate-unique-order-id new-id)))))
