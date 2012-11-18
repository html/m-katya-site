(in-package :m-katya-site)

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
        (:h1 "Коллекции")))

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
      :item-form-view (defview nil (:type form :persistp t :inherit-from '(:scaffold shop-item) :buttons '((:submit . "Save") (:cancel . "Close")))
                               (description :present-as textarea)))

    (lambda (&rest args)
      (with-html (:br)))))

