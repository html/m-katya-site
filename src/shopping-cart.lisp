(in-package :m-katya-site)

(defvar *shopping-cart-key* 'shopping-cart)

(defun add-item-to-shopping-cart (id &optional (count 1))
  (if (assoc id (webapp-session-value *shopping-cart-key*) :test #'=)
    (incf (cdr (assoc id (webapp-session-value *shopping-cart-key*) :test #'=)) count)
    (push (cons id count) (webapp-session-value *shopping-cart-key*))))

(defun list-shopping-cart-items ()
  (webapp-session-value *shopping-cart-key*))

(defun shopping-cart-empty-p () 
  (not (list-shopping-cart-items)))

(defun shopping-cart-items-count ()
  (apply #'+ (mapcar #'cdr (list-shopping-cart-items))))

(defun remove-item-from-shopping-cart (id)
  (setf (webapp-session-value *shopping-cart-key*) 
        (remove (assoc id (webapp-session-value *shopping-cart-key*) :test #'=) 
                (webapp-session-value *shopping-cart-key*) :test #'equal)))

(defun increase-item-count-in-shopping-cart (id &optional (count 1))
  (add-item-to-shopping-cart id count))

(defun decrease-item-count-in-shopping-cart (id &optional (count 1))
  (let ((item (assoc id (webapp-session-value *shopping-cart-key*) :test #'=)))
    (if (<= (cdr item) count)
      (remove-item-from-shopping-cart id)
      (decf (cdr item) count))))

(defun empty-shopping-cart ()
  (delete-webapp-session-value *shopping-cart-key*))
