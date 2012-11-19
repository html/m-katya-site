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
                                        (<:a :href link (<:as-is title))))))
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
  ((weblocks-mustache-template:variables :initform '((page-title . "Shop") (shop-active-p . t)))
   (current-category :initarg :current-category :initform nil)
   (current-page :initarg :current-page :initform nil)))

(mustache:defmustache 
  shop-list-layout 
  (yaclml:with-yaclml-output-to-string
    (<:div :class "row-fluid"
           (<:div :class "well span3" :style "padding:8px 0;"
                  (<:ul :class "nav nav-list"
                        (<:as-is "{{#nav-item}}")
                        (<:li :class "{{#active-p}}active{{/active-p}}"
                              (<:a :href "{{{shop-item-url}}}" 
                                   (<:i :class "icon-chevron-right pull-right")
                                   (<:as-is "{{title}}")))
                        (<:as-is "{{/nav-item}}")
                        (<:as-is "{{^nav-item}}")
                        (<:li (<:span "No items"))
                        (<:as-is "{{/nav-item}}")))
           (<:div :class "span9"
                  (<:div :class "row-fluid"
                         (<:as-is "{{#thumbnails-rows}}")
                         (<:ul :class "thumbnails"
                               (<:as-is "{{#thumbnails}}")
                               (<:li :class "span4" 
                                     (<:a :href "{{url}}" :class "thumbnail"
                                          (<:img :src "{{image-url}}")
                                          (<:div :class "caption"
                                                 (<:h3 (<:as-is "{{shop-item-title}}")))))
                               (<:as-is "{{/thumbnails}}"))
                         (<:as-is "{{/thumbnails-rows}}")
                         (<:as-is "{{^thumbnails-rows}}")
                         (<:div :class "span12 well" "No items")
                         (<:as-is "{{/thumbnails-rows}}"))))))

(yaclml::def-simple-xtag <:a)

(mustache:defmustache 
  shop-item-layout 
  (yaclml:with-yaclml-output-to-string
    (<:div :class "row-fluid"
           (<:div :class "well span3" :style "padding:8px 0;"
                  (<:ul :class "nav nav-list"
                        (<:as-is "{{#nav-item}}")
                        (<:li :class "{{#active-p}}active{{/active-p}}"
                              (<:a :href "{{shop-item-url}}" 
                                   (<:i :class "icon-chevron-right pull-right")
                                   (<:as-is "{{title}}")))
                        (<:as-is "{{/nav-item}}")
                        (<:as-is "{{^nav-item}}")
                        (<:li (<:span "No items"))
                        (<:as-is "{{/nav-item}}")))
           (<:div :class "span9"
                  (<:div :class "row-fluid"
                         (<:as-is "{{#thumbnails-rows-exist-p}}")
                         (<:div :class "span8"
                                (<:div :class "row-fluid"
                                       (<:div :id "myCarousel" :class "carousel slide span12 thumbnail" :style "height:400px;"
                                              (<:div :class "carousel-inner"
                                                     (<:as-is "{{#big-images}}")
                                                     (<:div :class "{{#active-p}}active {{/active-p}}item" :style "text-align:center;line-height:400px;height:400px;"
                                                            (<:img :style "display:inline;display:inline-table;display:inline-block;vertical-align:middle;" :src "{{image-url}}"))
                                                     (<:as-is "{{/big-images}}"))
                                              (<:a :class "carousel-control left" :href "#myCarousel" :data-slide "prev" (<:as-is"&lsaquo;"))
                                              (<:a :class "carousel-control right" :href "#myCarousel" :data-slide "next" (<:as-is"&rsaquo;"))) 
                                       (<:as-is "{{#thumbnails-rows}}") 
                                       (<:ul :class "thumbnails carousel-thumbnails"
                                             (<:as-is "{{#thumbnails}}")
                                             (<:li :class "span3" 
                                                   (<:a :href "javascript:;" :class "thumbnail"
                                                        (<:img :src "{{image-url}}")))
                                             (<:as-is "{{/thumbnails}}")) 
                                       (<:as-is "{{/thumbnails-rows}}")) 
                                (<:as-is "{{^thumbnails-rows}}") 
                                (<:div :class "span12" "No images to display") 
                                (<:as-is "{{/thumbnails-rows}}"))
                         (<:as-is "{{/thumbnails-rows-exist-p}}")
                         (<:script :type "text/javascript"
                                   (<:as-is 
                                     (ps:ps 
                                       (ps:chain (j-query ".carousel-thumbnails li a") 
                                                 (click (lambda ()
                                                          (ps:chain 
                                                            (j-query ".carousel")
                                                            (carousel 
                                                              (ps:chain 
                                                                (j-query ".carousel-thumbnails li") 
                                                                (index (ps:chain (j-query this) (parents "li")))))))))
                                       (ps:chain (j-query ".carousel") 
                                                 (carousel (ps:create :interval nil))
                                                 (carousel 0)
                                                 (bind "slid" (lambda ()
                                                                (let ((index (ps:chain (j-query ".carousel .item") (index (j-query ".carousel .item.active")))))
                                                                  (ps:chain (j-query ".carousel-thumbnails .selected") (remove-class "selected")) 
                                                                  (ps:chain 
                                                                    (j-query 
                                                                      (ps:chain (j-query ".carousel-thumbnails li a") (get index))) 
                                                                    (add-class "selected"))))))
                                       (ps:chain (j-query ".carousel-thumbnails li:first a") (add-class "selected")))))

                         (<:div :class "span4"
                                (<:as-is "{{#description}}")
                                (<:as-is "{{description}}")
                                (<:br)
                                (<:as-is "{{/description}}")
                                (<:br)
                                (<:b "Price: ")
                                (<:as-is "{{price}}")
                                (<:br)
                                (<:br)
                                (<:a :class "btn btn-large btn-primary" "Buy")))))))

(defun shop-item-nav-item (current-category)
  (loop for i in (list-shop-items-categories) 
        collect 
        (list 
          (cons :title i)
          (cons :active-p (string= i current-category))
          (cons :shop-item-url (format nil "/shop/~A" (url-encode i))))))

(defun shop-item-category-thumbnails (category)
  (loop for i in (shop-items-by-category category)
        collect (list 
                  (cons :shop-item-title (shop-item-title i))
                  (cons :url (format nil "/shop/~A/~A" (url-encode (shop-item-category-title i)) (object-id i)))
                  (cons :image-url (shop-item-list-thumbnail i)))))

(defun shop-item-category-thumbnails-for-mustache (category)
  (loop for i in (chunk-list (shop-item-category-thumbnails category) 3)
        collect (list (cons :thumbnails i)))) 

(defun shop-item-thumbnails (shop-item)
  (loop for i in (slot-value shop-item 'files)
        collect (list 
                  ;(cons :url (format nil "/shop/~A/~A" (shop-item-category-title i) (object-id i)))
                  (cons :image-url (collection-small-image i)))))

(defun shop-item-thumbnails-for-mustache (shop-item)
  (loop for i in (chunk-list (shop-item-thumbnails shop-item) 4)
        collect (list (cons :thumbnails i)))) 

(defmethod mustache-template-mixin-variables :around ((widget shop-page))
  (with-slots (current-category current-page) widget
    (append 
      (call-next-method)
      (list 
        (cons :page-title 
              (if current-page 
                (shop-item-title current-page)
                current-category))
        (cons :content 
              (with-output-to-string (str)
                (with-mustache-output-to str 
                  (if current-page
                    (shop-item-layout 
                      (list 
                        (cons :nav-item (shop-item-nav-item current-category))
                        (cons :thumbnails-rows (shop-item-thumbnails-for-mustache current-page))
                        (cons :thumbnails-rows-exist-p (not (not (shop-item-thumbnails-for-mustache current-page))))
                        (cons :price (shop-item-price current-page))
                        (cons :description (shop-item-description current-page))
                        (let ((images (shop-item-thumbnails current-page)))
                          (when images
                            (push (cons :active-p t) (first images)))
                          (cons :big-images images))))
                    (shop-list-layout 
                      (list 
                        (cons :nav-item (shop-item-nav-item current-category))
                        (cons :thumbnails-rows (shop-item-category-thumbnails-for-mustache current-category))))))))))))

(defun init-user-session (comp)
  (setf (composite-widgets comp)
        (make-instance 
          'static-selector 
          :panes (list 
                   (cons nil (make-instance 'about-us-page))
                   (cons "about-us" (make-instance 'about-us-page))
                   (cons "contacts" (make-instance 'contacts-page))
                   (cons "shop" (make-instance 
                                  'callback-selector-widget 
                                  :lookup-function (lambda (widget tokens)
                                                     (let ((category-param-exists-in-request-p (not tokens))
                                                           (some-collection-exists-p (first-of 'shop-item)))
                                                       (when (and category-param-exists-in-request-p some-collection-exists-p) 
                                                         (redirect 
                                                           (format nil "/shop/~A" (url-encode (first (list-shop-items-categories))))
                                                           :defer nil)))
                                                     (assert (<= (length tokens) 2))
                                                     (let ((item (and (first tokens) 
                                                                      (first-by-values 'shop-item :category-title (first tokens))))
                                                           (current-item (and (second tokens)
                                                                              (first-by-values 'shop-item :id (parse-integer (second tokens))))))
                                                       (values 
                                                         (make-instance 'shop-page 
                                                                        :current-category (shop-item-category-title item)
                                                                        :current-page current-item)
                                                         tokens nil :no-cache)))))
                   ;(cons "collections" (make-instance 'collections-page))
                   (cons "services" (make-instance 'services-page))
                   (cons "admin" (make-init-widgets))
                   (cons "collections"
                         (make-instance 
                           'callback-selector-widget 
                           :lookup-function (lambda (widget tokens)
                                              (let ((id-param-exists-in-request-p (not tokens))
                                                    (some-collection-exists-p (first-of 'collection)))
                                                (when (and id-param-exists-in-request-p some-collection-exists-p) 
                                                  (redirect 
                                                    (format nil "/collections/~A" (object-id (first-of 'collection)))
                                                    :defer nil)))
                                              (assert (<= (length tokens) 1))
                                              (let ((item (and (first tokens) (first-by-values 'collection :id (parse-integer (first tokens))))))
                                                (values (make-instance 'collections-page :current-page item) tokens nil)))))))))
