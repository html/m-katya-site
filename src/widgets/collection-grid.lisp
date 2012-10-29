(in-package :m-katya-site)

(defmacro with-yaclml (&body body)
  "A wrapper around cl-yaclml with-yaclml-stream macro."
  `(yaclml:with-yaclml-stream *weblocks-output-stream*
     ,@body))


(defwidget collection-grid (gridedit)
  ())

(defmethod dataedit-create-drilldown-widget ((grid collection-grid) item)
  (make-instance 'composite
                 :dom-class "drilldown-composite"
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
                                (loop for i in (slot-value item 'files) do 
                                      (<:div :style "float:left;padding:10px;"
                                             (<:img :src (collection-small-image i))))
                                (<:div :style "clear:both")))
                            (make-quickform 
                              (defview nil 
                                       (:type form 
                                        :caption ""
                                        :buttons '((:submit . "Upload file") (:cancel . "Close"))
                                        :persistp nil 
                                        :enctype "multipart/form-data" 
                                        :use-ajax-p nil)
                                       (upload-image :present-as (file-upload)
                                                     :parse-as (file-upload 
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
                                                           "Успешно добавлена картинка")
                                            (mark-dirty form)
                                            (setf (dataform-ui-state form) :form))
                              :on-cancel (when (eql (gridedit-drilldown-type grid) :edit)
                                           (lambda (obj)
                                             (declare (ignore obj))
                                             (dataedit-reset-state grid)
                                             (throw 'annihilate-dataform nil)))))))
