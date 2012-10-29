(in-package :m-katya-site)

(defmacro with-yaclml (&body body)
  "A wrapper around cl-yaclml with-yaclml-stream macro."
  `(yaclml:with-yaclml-stream *weblocks-output-stream*
     ,@body))

(defun create-single-pages ()
  (or weblocks:*default-store* (weblocks:open-stores))
  (loop for i in (list 
                   (list :title "О нас" :name "about-us" :content "")
                   (list :title "Контакты" :name "contacts" :content "")
                   (list :title "Услуги" :name "services" :content "")) do 

        (unless (weblocks-utils:first-by
                  'page 
                  (lambda (item)
                    (string= (page-title item) (getf i :title))))
          (persist-object *default-store* (apply #'make-instance (list* 'page i)))))) 

(create-single-pages)

(defun strip-tags (string)
  (cl-ppcre:regex-replace-all "<[^>]*>" string ""))

;; Define callback function to initialize new sessions
(defun make-init-widgets ()
  (list 
    (lambda (&rest args)
      (with-html
        (:h1 "Страницы")))
    (make-instance 
      'pages-grid 
      :data-class 'page 
      :item-form-view (defview nil (:type form :persistp t :inherit-from '(:scaffold page))
                               (content :present-as tinymce-textarea))
      :view (defview nil (:type table :inherit-from '(:scaffold page))
                     (content :present-as html 
                              :reader (lambda (item)
                                        (strip-tags (page-content item))))))
    (lambda (&rest args)
      (with-html
        (:h1 "Колекции")))

    (make-instance 
      'gridedit 
      :data-class 'collection 
      :view (defview nil (:type table :inherit-from '(:scaffold collection))
                     (files-count :present-as html 
                                  :reader (lambda (item)
                                            (write-to-string (length (slot-value item 'files))))))
      :item-form-view (defview nil (:type form :persistp t :inherit-from '(:scaffold collection)
                                    :enctype "multipart/form-data" 
                                    :use-ajax-p nil)
                               (images 
                                 :present-as html 
                                 :reader (lambda (item)
                                           (with-yaclml 
                                             (loop for i in (slot-value item 'files) do 
                                                   (<:div :style "float:left;padding:10px;"
                                                     (<:img :src (collection-small-image i))))
                                             (<:div :style "clear:both"))
                                           ""))
                               (upload-image :present-as (file-upload)
                                             :parse-as (file-upload 
                                                         :upload-directory (get-upload-directory)
                                                         :file-name :unique)
                                             :reader (lambda (item) 
                                                       nil)
                                             :writer (lambda (value object)
                                                       (when value 
                                                         (push value (slot-value object 'files)))))))))

(defun init-user-session (comp)
  (setf (composite-widgets comp)
        (make-init-widgets)))
