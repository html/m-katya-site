(in-package :m-katya-site)

(cl-config:set-value :weblocks.tinymce-textarea-presentation.tinymce-settings "({
                        debug: true,
                        script_url : '/pub/scripts/tiny_mce/tiny_mce.js',

                        theme : 'advanced',
                        plugins : 'pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template',

                        theme_advanced_buttons1: 'save,newdocument,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,styleselect,formatselect,fontselect,fontsizeselect',
                        theme_advanced_buttons2: 'cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor',
                        theme_advanced_buttons3: 'tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen',
                        theme_advanced_buttons4: 'insertlayer,moveforward,movebackward,absolute,|,styleprops,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,pagebreak',
                        theme_advanced_toolbar_location: 'top',
                        theme_advanced_toolbar_align: 'left',
                        theme_advanced_statusbar_location: 'bottom',
                        theme_advanced_resizing: true
                })")

(defclass tinymce-textarea-presentation (textarea-presentation)
  ())

(defmethod render-view-field-value :around (value (presentation tinymce-textarea-presentation) 
                                                  (field form-view-field) (view form-view) widget obj
                                                  &rest args)
  (declare (special weblocks:*presentation-dom-id*))
  (with-javascript
    (parenscript:ps*
      `(with-scripts 
         "/pub/scripts/tiny_mce/jquery.tinymce.js"
         (lambda () 
           (ps:chain 
             ($ ,(concatenate 'string "#" weblocks:*presentation-dom-id*)) 
             (tinymce 
               (eval ,(cl-config:get-value 
                        :weblocks.tinymce-textarea-presentation.tinymce-settings 
                        value presentation field view widget obj))))))))
  (call-next-method))
