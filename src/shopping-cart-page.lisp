(in-package :m-katya-site)

(mustache:defmustache shopping-cart-layout 
                      (yaclml:with-yaclml-output-to-string
                        (<:as-is "{{#shopping-cart-items-exist-p}}")
                        (<:table :class "table table-striped"
                                 (<:thead 
                                   (<:tr 
                                     (<:th "#")
                                     (<:th "Item name")
                                     (<:th "Count")
                                     (<:th)))
                                 (<:tbody
                                   (<:as-is "{{#shopping-cart-items}}") 
                                   (<:tr 
                                     (<:td "{{order-number}}")
                                     (<:td 
                                       (<:a 
                                         :target "_blank"
                                         :href "{{shop-item-url}}"
                                         "{{title}}"))
                                     (<:td "{{count}}")
                                     (<:td 
                                       (<:div :class "btn-toolbar"
                                              (<:div :class "btn-group"
                                                     (<:a :href "{{shop-item-increase-cart-items-url}}" :class "btn btn-primary" (<:i :class "icon-plus-sign icon-white"))
                                                     (<:a :href "{{shop-item-decrease-cart-items-url}}" :class "btn btn-primary" (<:i :class "icon-minus-sign icon-white"))) 
                                              (<:div :class "btn-group"
                                                     (<:a :href "{{shop-item-remove-from-cart-url}}" :class "btn btn-danger" 
                                                          (<:i :class "icon-remove")))))) 
                                   (<:as-is "{{/shopping-cart-items}}"))) 
                        (<:as-is "{{{order-link}}}")
                        (<:as-is "{{/shopping-cart-items-exist-p}}")
                        (<:as-is "{{^shopping-cart-items-exist-p}}")
                        (<:div :class "alert" 
                               (<:i :class "icon-info-sign")
                               (<:as-is "&nbsp;")
                               (<:as-is "Shopping cart is empty"))
                        (<:as-is "{{/shopping-cart-items-exist-p}}")))

(defwidget shopping-cart-page (main-page)
  ((weblocks-mustache-template:variables :initform '((shopping-cart-active-p . t)))))

(defun shopping-cart-remove-item-action (&rest args)
  (let* ((shop-item-id (parse-integer (getf args :id)))
         (shop-item (first-by-values 'shop-item :id shop-item-id)))
    (remove-item-from-shopping-cart (object-id shop-item))
    (redirect "/shopping-cart" :defer nil)))

(defun shopping-cart-decrease-item-count-action (&rest args)
  (let* ((shop-item-id (parse-integer (getf args :id)))
         (shop-item (first-by-values 'shop-item :id shop-item-id)))
    (decrease-item-count-in-shopping-cart (object-id shop-item))
    (redirect "/shopping-cart" :defer nil)))

(defun shopping-cart-increase-item-count-action (&rest args)
  (let* ((shop-item-id (parse-integer (getf args :id)))
         (shop-item (first-by-values 'shop-item :id shop-item-id)))
    (increase-item-count-in-shopping-cart (object-id shop-item))
    (redirect "/shopping-cart" :defer nil)))

(defun list-shopping-cart-items-for-mustache (increase-url decrease-url remove-url)
  (loop for (i . count) in (list-shopping-cart-items) 
        for j from 1
        collect (let ((shop-item (first-by-values 'shop-item :id i)))
                  (list 
                    (cons :order-number j)
                    (cons :count count)
                    (cons :title (shop-item-title shop-item))
                    (cons :shop-item-url (shop-item-url shop-item))
                    (cons :shop-item-remove-from-cart-url
                          (add-get-param-to-url 
                            remove-url
                            (string :id) 
                            (write-to-string (object-id shop-item))))
                    (cons :shop-item-decrease-cart-items-url
                          (add-get-param-to-url 
                            decrease-url
                            (string :id) 
                            (write-to-string (object-id shop-item))))
                    (cons :shop-item-increase-cart-items-url 
                          (add-get-param-to-url 
                            increase-url
                            (string :id) 
                            (write-to-string (object-id shop-item))))))))

(defmethod mustache-template-mixin-variables :around ((widget shopping-cart-page))
  (list* 
    (cons 
      :content 
      (with-output-to-string (str)
        (with-mustache-output-to str 
          (shopping-cart-layout 
            (list 
              (cons :shopping-cart-items 
                    (list-shopping-cart-items-for-mustache
                      (make-action-url (function-or-action->action #'shopping-cart-increase-item-count-action))
                      (make-action-url (function-or-action->action #'shopping-cart-decrease-item-count-action))
                      (make-action-url (function-or-action->action #'shopping-cart-remove-item-action))))
              (cons :shopping-cart-items-exist-p (not (shopping-cart-empty-p)))
              (cons :order-link 
                    (capture-weblocks-output 
                      (render-link 
                        (make-action 
                          (lambda (&rest args)
                            (let ((order (make-instance 'order 
                                                        :items (list-shopping-cart-items)
                                                        :order-id (generate-unique-order-id))))
                              (persist-object *default-store* order) 
                              (empty-shopping-cart) 
                              (redirect (format nil "/order/~A" (slot-value order 'order-id)) :defer nil))))
                        "Order"
                        :class  "btn btn-primary btn-large pull-right")))
              )))))
    (cons :page-title "Shopping cart")
    (call-next-method)))
