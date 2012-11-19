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

(mustache:defmustache main-page 
                      (yaclml:with-yaclml-output-to-string 
                        (<:div :class "page-header"
                               (<:h1 
                                 (<:as-is "{{page-title}}")))
                        (<:style :type "text/css"
                                 ".page-header {margin-bottom:10px;}
                                  a.thumbnail.selected {
                                      border-color: #0088cc;
                                      -webkit-box-shadow: 0 1px 4px rgba(0, 105, 214, 0.25);
                                      -moz-box-shadow: 0 1px 4px rgba(0, 105, 214, 0.25);
                                      box-shadow: 0 1px 4px rgba(0, 105, 214, 0.25);
                                  }
                                  .carousel-control {
                                    top: 50%;
                                  }
                                  ")
                        (<:ul :class "nav nav-pills"
                              (flet ((get-page-title-for-name (name)
                                       (page-title (first-by-values 'page :name name))))
                                (loop for (title link class) 
                                      in (list 
                                           (list (get-page-title-for-name "about-us") "/" "about-us")
                                           (list (get-page-title-for-name "contacts") "/contacts" "contacts") 
                                           (list "Shop" "/shop" "shop") 
                                           (list "Collections" "/collections" "collections")
                                           (list (get-page-title-for-name "services") "/services" "services")) do 
                                      (<:li :class (format nil "{{#~A-active-p}}active{{/~A-active-p}}" class class)
                                        (<:a :href link (<:as-is title))))
                                (<:li :class "pull-right {{#shopping-cart-active-p}}active{{/shopping-cart-active-p}}"
                                        (<:a :href "/shopping-cart" 
                                          (<:as-is "Shopping cart" )
                                          (<:as-is "{{#shopping-cart-items-count}} <b>( {{shopping-cart-items-count}} )</b>{{/shopping-cart-items-count}}")))))
                        (<:as-is "{{{content}}}")))

(defwidget main-page (mustache-template-widget)
           ((weblocks-mustache-template:template :initform #'main-page)
            (weblocks-mustache-template:variables :initform '((form-title . "Test")))))

(defmethod mustache-template-mixin-variables :around ((widget main-page))
  (list* 
    (cons :shopping-cart-items-count (and (not (zerop (shopping-cart-items-count)))
                                          (shopping-cart-items-count)))
    (call-next-method)))

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

(defwidget order-page (main-page)
  ((item :initarg :item :initform nil)))

(mustache:defmustache order-layout 
                      (yaclml:with-yaclml-output-to-string
                        (<:div :class "alert" 
                               (<:as-is "Order with number <b>{{order-id}}</b> successfully created. ")
                               (<:as-is "Please remember it and ")
                               (<:a :href "/contacts" "contact us "))))

(defmethod mustache-template-mixin-variables :around ((widget order-page))
  (with-slots (item) widget
    (with-slots (order-id) item
      (list* 
        (cons 
          :content (with-output-to-string (str)
                     (with-mustache-output-to str 
                       (order-layout 
                         (list (cons :order-id order-id))))))
        (cons :page-title (format nil "Order ~A" order-id))
        (call-next-method)))))

