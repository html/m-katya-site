(in-package :m-katya-site)

(defun chunk-list (list size)
  (assert (> size 0))
  (let ((list (copy-list list)))
    (loop while list 
          collect 
          (loop for i from 1 to size while list collect (pop list)))))


