(in-package :m-katya-site)

(defwidget pages-grid (gridedit)
  ())

(defmacro hide-inherited-from-grid-widget-operations (widget)
  `(progn 
     ; All pages are predefined, there is no need to show these buttons
     (defmethod dataedit-update-operations ((widget ,widget) &rest args)
       (declare (ignore widget args)))

     (defmethod render-view-field-header ((field weblocks::datagrid-select-field) 
                                          (view table-view)
                                          (widget ,widget) presentation value obj 
                                          &rest args)
       (declare (ignore args)))

     (defmethod render-view-field ((field weblocks::datagrid-select-field) (view table-view)
                                                                           (widget ,widget) presentation value obj &rest args)
       (declare (ignore args)))
     
     (defmethod dataseq-render-mining-bar ((obj ,widget) &rest args)
       (declare (ignore args)))))

(hide-inherited-from-grid-widget-operations pages-grid)

; Hiding pagination
(defmethod dataseq-allow-pagination-p ((widget pages-grid))
  nil)
