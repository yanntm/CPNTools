(defun wiki-image-replace ()
  "Remove Wiki image anchors from HTML saved from Wiki page"
  (interactive)
  (query-replace-regexp "<a href=\".+\\.png\\.wiki\\?cmd=get&anchor=.+\\.png&type=image\">\\(<img border=0 src=\"_images/.+\\.png\" alt=\".+\\.png\">\\)</a>" "\\1" nil)
  )