(in-package :m-katya-site)

(defwidget collections-page (main-page)
  ((weblocks-mustache-template:variables :initform '((page-title . "Collections") (collections-active-p . t)))
   (current-page :initarg :current-page :initform nil)))

(mustache:defmustache 
  collections-layout 
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

(defun collections-nav-item (active-id)
  (loop for i in (all-of 'collection) 
        collect (list 
                  (cons :title (collection-title i))
                  (cons :active-p (equal (object-id i) active-id))
                  (cons :id (object-id i)))))

(defun collection-thumbnails (current-page)
  (loop for i in (slot-value current-page 'files)
        collect (list (cons :url (collection-small-image i)))))

(defmethod mustache-template-mixin-variables :around ((widget collections-page))
  (with-slots (current-page) widget
    (append 
      (list 
        (cons :content (with-output-to-string (str)
                         (with-mustache-output-to str 
                           (collections-layout (list 
                                                 (cons :nav-item (when current-page 
                                                                   (collections-nav-item (object-id current-page)))
                                                       #+l(list 
                                                            (list '(:title . "Item 1")
                                                                  '(:active-p . t))
                                                            (list '(:title . "Item 2"))
                                                            (list '(:title . "Item 3"))))
                                                 (cons :thumbnails-rows 
                                                       (when current-page 
                                                         (loop for i in 
                                                               (chunk-list 
                                                                 (collection-thumbnails current-page)
                                                                 3)
                                                               collect (list (cons :thumbnails i)))))))))))
      (call-next-method))))
