(in-package :m-katya-site)

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
        (:br)
        (:h1 "Колекции")))

    (make-instance 
      'collection-grid 
      :data-class 'collection 
      :view (defview nil (:type table :inherit-from '(:scaffold collection) )
                     (files-count :present-as html 
                                  :reader (lambda (item)
                                            (write-to-string (length (slot-value item 'files))))))
      :item-form-view (defview nil (:type form :persistp t :inherit-from '(:scaffold collection) :buttons '((:submit . "Save") (:cancel . "Close")))))
    (lambda (&rest args)
      (with-html 
        (:br)
        (:h1 "Магазин")))

    (make-instance 
      'collection-grid 
      :data-class 'shop-item
      :view (defview nil (:type table :inherit-from '(:scaffold shop-item) )
                     (files-count :present-as html 
                                  :reader (lambda (item)
                                            (write-to-string (length (slot-value item 'files))))))
      :item-form-view (defview nil (:type form :persistp t :inherit-from '(:scaffold shop-item) :buttons '((:submit . "Save") (:cancel . "Close")))))

    (lambda (&rest args)
      (with-html (:br)))))

(defun init-user-session (comp)
  (setf (composite-widgets comp)
        (make-init-widgets)))
