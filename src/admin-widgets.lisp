(in-package :m-katya-site)

(defun order-items-html-list (item &optional display-links-p)
  (yaclml:with-yaclml-output-to-string 
    (<:div :style "display:inline-block;"
           (<:dl :class "dl-horizontal"
                 (loop for (id . count) in (slot-value item 'items) do 
                       (let ((item (first-by-values 'shop-item :id id)))
                         (<:dt 
                           (if display-links-p 
                             (<:a :href (shop-item-url item) :target "_blank"
                                  (<:as-html (shop-item-title item)))
                             (<:as-html (shop-item-title item))))
                         (<:dd (<:as-is count))))))))

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
                     (content :present-as (excerpt :cutoff-threshold 300) 
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
      (with-html 
        (:br)
        (:h1 "Заказы")))
    
    (make-instance 
      'gridedit 
      :data-class 'order
      :view (defview nil (:type table :inherit-from '(:scaffold order))
                     (completed :present-as predicate)
                     (items :present-as html :reader #'order-items-html-list))
      :item-form-view (defview nil (:type form :persistp t :inherit-from '(:scaffold order) :buttons '((:submit . "Save") (:cancel . "Close")))
                               (completed :present-as (checkbox) 
                                          :parse-as predicate)
                               (notes :present-as textarea)
                               (items :present-as html :reader (lambda (item)
                                                                 (order-items-html-list item t)))))
    
    (lambda (&rest args)
      (with-html 
        (:br)))))

