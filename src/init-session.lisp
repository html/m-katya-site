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
      :item-form-view (defview nil (:type form :persistp t :inherit-from '(:scaffold shop-item) :buttons '((:submit . "Save") (:cancel . "Close")))))

    (lambda (&rest args)
      (with-html (:br)))))

(mustache:defmustache main-page 
                      (yaclml:with-yaclml-output-to-string 
                        (<:h1 
                          (<:as-is "{{page-title}}"))
                        (<:div :class "navbar"
                               (<:div :class "navbar-inner"
                                      (<:span :class "brand" "") 
                                      (<:ul :class "nav"
                                            (flet ((get-page-title-for-name (name)
                                                     (page-title (first-by-values 'page :name name))))
                                              (loop for (title link class) 
                                                    in (list 
                                                         (list (get-page-title-for-name "about-us") "/about-us" "about-us")
                                                         (list (get-page-title-for-name "contacts") "/contacts" "contacts") 
                                                         (list "Shop" "/shop" "shop") 
                                                         (list "Collections" "/collections" "collections")
                                                         (list (get-page-title-for-name "services") "/services" "services")) do 
                                                    (<:li :class (format nil "{{#~A-active-p}}active{{/~A-active-p}}" class class)
                                                      (<:a :href link (<:as-is title))))))))
                        (<:as-is "{{{content}}}")))

(defwidget main-page (mustache-template-widget)
           ((weblocks-mustache-template:template :initform #'main-page)
            (weblocks-mustache-template:variables :initform '((form-title . "Test")))))

(defwidget about-us-page (main-page)
  ((weblocks-mustache-template:variables :initform '((about-us-active-p . t)))))

(defmacro define-page-variables-method (widget-class page-name)
  `(defmethod mustache-template-mixin-variables :around ((widget ,widget-class))
     (let ((page (first-by-values 'page :name ,page-name)))
       (append 
         (list 
           (cons :page-title (page-title page))
           (cons :content (page-content page)))
         (call-next-method)))))

(defwidget contacts-page (main-page)
  ((weblocks-mustache-template:variables :initform '((contacts-active-p . t)))))

(defwidget services-page (main-page)
  ((weblocks-mustache-template:variables :initform '((services-active-p . t)))))

(define-page-variables-method about-us-page "about-us")
(define-page-variables-method contacts-page "contacts")
(define-page-variables-method services-page "services")

(defwidget shop-page (main-page)
  ((weblocks-mustache-template:variables :initform '((page-title . "Shop") (shop-active-p . t)))))

(mustache:defmustache 
  shop-layout 
  (yaclml:with-yaclml-output-to-string
    (<:div :class "row-fluid"
           (<:div :class "well span3" :style "padding:8px 0;"
                  (<:ul :class "nav nav-list"
                        (<:as-is "{{#nav-item}}")
                        (<:li :class "{{#active-p}}active{{/active-p}}"
                              (<:a :href "/collections/{{id}}" 
                                   (<:i :class "icon-chevron-right pull-right")
                                   (<:as-is "{{title}}")))
                        (<:as-is "{{/nav-item}}")
                        (<:as-is "{{^nav-item}}")
                        (<:li (<:span "No collections"))
                        (<:as-is "{{/nav-item}}")))
           (<:div :class "span9"
                  (<:div :class "row-fluid"
                         (<:as-is "{{#thumbnails-rows}}")
                         (<:ul :class "thumbnails"
                               (<:as-is "{{#thumbnails}}")
                               (<:li :class "span4" 
                                     (<:a :class "thumbnail"
                                          (<:img :src "{{url}}")))
                               (<:as-is "{{/thumbnails}}"))
                         (<:as-is "{{/thumbnails-rows}}")
                         (<:as-is "{{^thumbnails-rows}}")
                         (<:div :class "span12 well" "No Images")
                         (<:as-is "{{/thumbnails-rows}}"))))))


(defun init-user-session (comp)
  (setf (composite-widgets comp)
        (make-instance 
          'static-selector 
          :panes (list 
                   (cons nil (make-instance 'main-page))
                   (cons "about-us" (make-instance 'about-us-page))
                   (cons "contacts" (make-instance 'contacts-page))
                   (cons "shop" (make-instance 'shop-page))
                   ;(cons "collections" (make-instance 'collections-page))
                   (cons "services" (make-instance 'services-page))
                   (cons "admin" (make-init-widgets))
                   (cons "collections"
                         (make-instance 
                           'callback-selector-widget 
                           :lookup-function (lambda (widget tokens)
                                              (when (and (not tokens) (first-of 'collection)) 
                                                (redirect 
                                                  (format nil "/collections/~A" (object-id (first-of 'collection)))
                                                  :defer nil))
                                              (assert (<= (length tokens) 1))
                                              (let ((item (and (first tokens) (first-by-values 'collection :id (parse-integer (first tokens))))))
                                                (values (make-instance 'collections-page :current-page item) tokens nil)))))))))
