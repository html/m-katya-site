(in-package :m-katya-site)


(defclass collection ()
  ((id)
   (title :accessor collection-title)
   (files :initform nil)))

(defun get-upload-directory ()
  (merge-pathnames 
    (make-pathname :directory '(:relative "upload"))
    (compute-webapp-public-files-path (weblocks:get-webapp 'm-katya-site))))

(defun get-small-images-directory ()
  (merge-pathnames 
    (make-pathname :directory '(:relative "generated/100x100"))
    (compute-webapp-public-files-path (weblocks:get-webapp 'm-katya-site))))


(defun pathname-name-with-type (pathname)
  (concatenate 'string (pathname-name pathname) "." (pathname-type pathname)))

(defun collection-small-image (name)
  (let ((small-image-file-name
          (merge-pathnames 
            name
            (get-small-images-directory))))
    (unless (probe-file small-image-file-name)
      (resize-image 
        (merge-pathnames 
          name
          (get-upload-directory))
        small-image-file-name
        :target-width 213
        :target-height 213))
    (concatenate 'string "/pub/generated/100x100/" name)))

(defmethod remove-file ((obj collection) file-name)
  (with-slots (files) obj
    (when (find file-name files :test #'string=)
      (let  ((file-names (list 
                      (merge-pathnames file-name 
                                       (get-upload-directory))
                      (merge-pathnames file-name 
                                       (get-small-images-directory)))))
        (loop for i in file-names do 
              (when (probe-file i)
                (delete-file i))))
      (setf files (remove file-name files :test #'string=)))))
