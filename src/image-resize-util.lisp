(in-package :m-katya-site)

(defun calculate-inner-resize (source-width source-height target-width target-height)
  (let* ((coef-width (/ source-width target-width))
         (coef-height (/ source-height target-height))
         (coef (max coef-width coef-height))
         (actual-target-width (floor (/ source-width coef)))
         (actual-target-height (floor (/ source-height coef)))
         (actual-target-x 
           (floor 
             (if (< actual-target-width target-width)
               (/ (- target-width actual-target-width) 2)
               0)))
         (actual-target-y 
           (floor 
             (if (< actual-target-height target-height)
               (/ (- target-height actual-target-height) 2)
               0))))
    (values 0 0 actual-target-x actual-target-y actual-target-width actual-target-height)))

(assert (equal (calculate-inner-resize 200 100 100 100) (values 0 0  0 25 100  50)))
(assert (equal (calculate-inner-resize 300 100 100 100) (values 0 0  0 33 100  33)))
(assert (equal (calculate-inner-resize 100 200 100 100) (values 0 0 25  0  50 100)))

(defun resize-image (from-file-name to-file-name &key target-width target-height)
  (cl-gd:with-image-from-file (source-image from-file-name)
    (multiple-value-bind (source-width source-height) (cl-gd:image-size source-image)
      (cl-gd:with-image (new target-width target-height)
        (multiple-value-bind 
          (source-x source-y target-x target-y target-width-actual target-height-actual)
          (calculate-inner-resize 
            source-width source-height 
            target-width target-height)

          (cl-gd:copy-image 
            source-image new 
            source-x source-y 
            target-x target-y 
            source-width source-height 
            :resize t 
            :dest-width target-width-actual
            :dest-height target-height-actual)) 
        (cl-gd:write-image-to-file to-file-name 
                                   :image new 
                                   :if-exists :supersede)))))

