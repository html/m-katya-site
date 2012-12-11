(in-package :m-katya-site)

(defmacro with-yaclml (&body body)
  "A wrapper around cl-yaclml with-yaclml-stream macro."
  `(yaclml:with-yaclml-stream *weblocks-output-stream*
     ,@body))


(defwidget collection-grid (gridedit)
  ())

(defmethod dataedit-create-drilldown-widget ((grid collection-grid) item)
  (make-instance 'composite
                 :dom-class "drilldown-composite well"
                 :widgets (list
                            (make-quickform 
                              (dataedit-item-form-view grid)
                              :data item
                              :class-store (dataseq-class-store grid)
                              :on-success (lambda (form obj)
                                            (declare (ignore obj))
                                            (mark-dirty grid)
                                            (flash-message (dataseq-flash grid)
                                                           (format nil "Modified ~A."
                                                                   (humanize-name (dataseq-data-class grid)))))
                              :on-cancel (when (eql (gridedit-drilldown-type grid) :edit)
                                           (lambda (obj)
                                             (declare (ignore obj))
                                             (dataedit-reset-state grid)
                                             (throw 'annihilate-dataform nil))))
                            (lambda (&rest args)
                              (with-yaclml 
                                (<:h2 "Картинки к элементу")
                                (let ((action-url (make-action-url 
                                                    (make-action 
                                                      (lambda (&rest args)
                                                        (let ((id (parse-integer (getf args :id)))
                                                              (file (getf args :file)))
                                                          (remove-file 
                                                            (weblocks-utils:first-by-values (dataseq-data-class grid) :id id)
                                                            file))
                                                        (redirect "/admin" :defer nil))))))
                                  (loop for i in (slot-value item 'files) do 
                                        (<:div :style "float:left;padding:15px;text-align:right;position:relative;"
                                               (<:div :style "position:absolute;right:0px;top:15px;font-size:20px;" :class "remove-image-link"
                                                      (<:a :href 
                                                           (add-get-param-to-url 
                                                             (add-get-param-to-url action-url 
                                                                                   "id"
                                                                                   (write-to-string (object-id item)))
                                                             "file"
                                                             i)  "[x]"))
                                               (<:br)
                                               (<:img :src (collection-small-image i)))))
                                (<:div :style "clear:both")))
                            (make-quickform 
                              (defview nil 
                                       (:type form 
                                              :caption ""
                                              :buttons '((:submit . "Upload file") (:cancel . "Close"))
                                              :persistp nil 
                                              :enctype "multipart/form-data" 
                                              :use-ajax-p t)
                                       (upload-image :present-as (ajax-file-upload)
                                                     :parse-as (ajax-file-upload 
                                                                 :upload-directory (get-upload-directory)
                                                                 :file-name :unique)
                                                     :reader (lambda (item) 
                                                               nil)
                                                     :writer (lambda (value object)
                                                               (when value 
                                                                 (push value (slot-value item 'files))))))
                              :answerp nil
                              :on-success (lambda (form data)
                                            (flash-message (dataseq-flash grid)
                                                           "Successfully added image")
                                            (mark-dirty form)
                                            (mark-dirty (root-widget))
                                            (setf (dataform-ui-state form) :form))
                              :on-cancel (when (eql (gridedit-drilldown-type grid) :edit)
                                           (lambda (obj)
                                             (declare (ignore obj))
                                             (dataedit-reset-state grid)
                                             (throw 'annihilate-dataform nil)))))))
