(in-package :m-katya-site)

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
                                                     (let ((category-param-does-not-exist-in-request-p (not tokens))
                                                           (some-collection-exists-p (first-of 'shop-item)))
                                                       (when (and category-param-does-not-exist-in-request-p some-collection-exists-p) 
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
                   (cons "shopping-cart" (make-instance 'shopping-cart-page))
                   (cons "admin" (make-init-widgets))
                   (cons "collections"
                         (make-instance 
                           'callback-selector-widget 
                           :lookup-function (lambda (widget tokens)
                                              (let ((id-param-does-not-exist-in-request-p (not tokens))
                                                    (some-collection-exists-p (first-of 'collection)))
                                                (when (and id-param-does-not-exist-in-request-p some-collection-exists-p) 
                                                  (redirect 
                                                    (format nil "/collections/~A" (object-id (first-of 'collection)))
                                                    :defer nil)))
                                              (assert (<= (length tokens) 1))
                                              (let ((item (and (first tokens) (first-by-values 'collection :id (parse-integer (first tokens))))))
                                                (values (make-instance 'collections-page :current-page item) tokens nil)))))
                   (cons "order" 
                         (make-instance 
                           'callback-selector-widget 
                           :lookup-function (lambda (widget tokens)
                                              (let ((id-param-exists-in-request-p tokens)
                                                    (order (first-by-values 'order :order-id (parse-integer (first tokens)))))
                                                (when (and id-param-exists-in-request-p order) 
                                                  (values (make-instance 'order-page :item order) tokens nil))))))))))
