(in-package :m-katya-site)

(defwidget pages-grid (gridedit)
  ())

; All pages are predefined, there is no need to show these buttons
(defmethod dataedit-update-operations ((widget pages-grid) &rest args)
  )
