;;; wiki-mode: Major mode for editing WIKI hypertext documents.

;; Copyright (C) 1985 Free Software Foundation, Inc.
;; Copyright (C) 1992, 1993 National Center for Supercomputing Applications.
;; NCSA modifications by Marc Andreessen (marca@ncsa.uiuc.edu).
;; Copyright (C) 1995 Howard R. Melman <melman@osf.org>
;; Copyright (C) 1995 Peter Andersen (pa@mjolner.com)

;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You didn't receive a copy of the GNU General Public License along
;; with this program; so, write to the Free Software Foundation, Inc.,
;; 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:
;;    One of theories in the design of this mode is that people can
;;    type in the buffer better than they can in the minibuffer.
;;    Therefore very few values are prompted for, but instead the tags
;;    are inserted in the text and point positioned relevantly.
;;    None of the commands change mark.  For all commands where it makes
;;    sense, a prefix arguement means to operate on the region.  This
;;    means there are no extra commands or bindings to learn (or to
;;    fit on menus).
;;
;;    The keys bindings are long, but they do meet Emacs style.
;;    No commands are bound to C-c <letter>, leaving these for the
;;    user. 

;;  This package is based on:
;;    html-mode.el   version 2.0  by Marc Andresssen
;;    html-extras.el version 1.12 by Sean Dowd. 
;;    html-mode.el   version 3.0: by Howard R. Melman <melman@osf.org>


;;; ------------------------------ INSTRUCTIONS ------------------------------
;; 
;;  Put the following code in your .emacs file:
;; 
;;  (autoload 'wiki-mode "wiki-mode" "WIKI major mode." t)
;;  (or (assoc "\\.wiki$" auto-mode-alist)
;;    (setq auto-mode-alist (cons '("\\.wiki$" . wiki-mode) 
;;                                auto-mode-alist)))
;; 
;;  Emacs will detect the ``.wiki'' suffix and activate wiki-mode
;;  appropriately.

;;; ------------------------INTERNAL VARIABLES--------------------------------

(defvar wiki-mode-version "1.0"
  "Version number of wiki-mode.el")

(defvar wiki-mode-syntax-table nil
  "Syntax table used while in wiki mode.")

(defvar wiki-mode-abbrev-table nil
  "Abbrev table used while in wiki mode.")
(define-abbrev-table 'wiki-mode-abbrev-table ())

(if wiki-mode-syntax-table
    ()
  (setq wiki-mode-syntax-table (make-syntax-table))
  ;; anything to do for something like &amp;
;;  (modify-syntax-entry ?<  "(>"  wiki-mode-syntax-table)
;;  (modify-syntax-entry ?>  ")<"  wiki-mode-syntax-table)
;;  (modify-syntax-entry ?=  ". "  wiki-mode-syntax-table)
  (modify-syntax-entry ?\" ". "  wiki-mode-syntax-table)
  (modify-syntax-entry ?\\ ". "  wiki-mode-syntax-table)
  (modify-syntax-entry ?'  "w "  wiki-mode-syntax-table))

(defvar wiki-mode-map nil 
  "Keymap used in WIKI mode")
(if wiki-mode-map
    ()
  (setq wiki-mode-map (make-sparse-keymap))
  (define-key wiki-mode-map "\C-c1"        'wiki-add-header-1)
  (define-key wiki-mode-map "\C-c2"        'wiki-add-header-2)
  (define-key wiki-mode-map "\C-c3"        'wiki-add-header-3)
  (define-key wiki-mode-map "\C-c4"        'wiki-add-header-4)

  (define-key wiki-mode-map "\C-c\C-co"    'wiki-add-code)
  (define-key wiki-mode-map "\C-c\C-cb"    'wiki-add-bold)
  (define-key wiki-mode-map "\C-c\C-ci"    'wiki-add-italics)
  (define-key wiki-mode-map "\C-c\C-p"     'wiki-add-preformatted)
  (define-key wiki-mode-map "\C-c\C-xb"    'wiki-add-br)
  (define-key wiki-mode-map "\C-c\C-xh"    'wiki-add-hr)

  (define-key wiki-mode-map "\C-c\C-k"     'wiki-add-link)
  (define-key wiki-mode-map "\C-c\C-i"     'wiki-add-image-link)
  (define-key wiki-mode-map "\C-c\C-h"     'wiki-add-http-link)
  (define-key wiki-mode-map "\C-c\C-m"     'wiki-add-mailto-link)
  (define-key wiki-mode-map "\C-c\C-d"     'wiki-add-doc-link)
  (define-key wiki-mode-map "\C-c\C-w"     'wiki-add-wiki-link)

  (define-key wiki-mode-map "\C-c\C-li"    'wiki-add-list-item)
  (define-key wiki-mode-map "\C-c\C-ln"    'wiki-add-numbered-list-item)
  (define-key wiki-mode-map "\C-c\C-lt"    'wiki-add-term-definition)

  (define-key wiki-mode-map "\C-c\C-tt"    'wiki-add-table)
  (define-key wiki-mode-map "\C-c\C-tr"    'wiki-add-table-row)
  (define-key wiki-mode-map "\C-c\C-td"    'wiki-add-table-data)

  ;; Function keys
  (define-key wiki-mode-map [f1]   
    (function (lambda () (interactive)(wiki-add-header-1 1))))
  (define-key wiki-mode-map [f2]   
    (function (lambda () (interactive)(wiki-add-header-2 1))))
  (define-key wiki-mode-map [f3]   
    (function (lambda () (interactive)(wiki-add-header-3 1))))
  (define-key wiki-mode-map [f4]   
    (function (lambda () (interactive)(wiki-add-header-4 1))))
  
  (define-key wiki-mode-map [f5]   
    (function (lambda () (interactive)(wiki-add-code 1))))
  (define-key wiki-mode-map [f6]   
    (function (lambda () (interactive)(wiki-add-bold 1))))
  (define-key wiki-mode-map [f7]   
    (function (lambda () (interactive)(wiki-add-italic 1))))

)

;;; ------------------------------- wiki-mode --------------------------------

;;;###autoload
(defun wiki-mode ()
  "Major mode for editing WIKI hypertext documents.

Turning on wiki-mode calls the value of the variable text-mode-hook, 
and wiki-mode-hook in that order, if those values are non-nil.

Special commands:
\\{wiki-mode-map}

Notice that the function keys F1-F7 applies the fomatting to the
selected text, if any."
  (interactive)
  (kill-all-local-variables)
  (use-local-map wiki-mode-map)
  (setq mode-name "WIKI")
  (setq major-mode 'wiki-mode)
  (setq local-abbrev-table wiki-mode-abbrev-table)
  (set-syntax-table wiki-mode-syntax-table)
  ;; Do the hooks
  (run-hooks 'text-mode-hook 'wiki-mode-hook)
  )

;;; -------------------------- Text Commands --------------------------------

(defun wiki-add-header (size &optional arg)
  "Add a header."
  (interactive "*sSize (*,=,-,_): \nP")
  (wiki-add-tag-internal (concat size size size) " " arg))

(defun wiki-add-header-1 (&optional arg)
  "Add a level 1 header.
If called with a PREFIX argument surround region with header markup."
  (interactive "*P")
  (wiki-add-header "*" arg))

(defun wiki-add-header-2 (&optional arg)
  "Add a level 2 header.
If called with a PREFIX argument surround region with header markup."
  (interactive "*P")
  (wiki-add-header "=" arg))

(defun wiki-add-header-3 (&optional arg)
  "Add a level 3 header.
If called with a PREFIX argument surround region with header markup."
  (interactive "*P")
  (wiki-add-header "-" arg))

(defun wiki-add-header-4 (&optional arg)
  "Add a level 4 header.
If called with a PREFIX argument surround region with header markup."
  (interactive "*P")
  (wiki-add-header "_" arg))

(defun wiki-add-code (&optional arg)
  "Add a code formatting directive to buffer leaving point inside.
If called with a PREFIX argument surround region with code."
  (interactive "*P")
  (wiki-add-tag-internal "\"\"" "" arg))

(defun wiki-add-bold (&optional arg)
  "Add a bold formatting directive to buffer leaving point inside.
If called with a PREFIX argument surround region with bold."
  (interactive "*P")
  (wiki-add-tag-internal "__" "" arg))

(defun wiki-add-italics (&optional arg)
  "Add an italics formatting directive to buffer leaving point inside.
If called with a PREFIX argument surround region with italics."
  (interactive "*P")
  (wiki-add-tag-internal "''" "" arg))

(defun wiki-add-preformatted (&optional arg)
  "Add a preformatted formatting directive to buffer leaving point inside.
If called with a PREFIX argument surround region with preformatted markup."
  (interactive "*P")
  (wiki-add-tag-internal "<<<"  "" arg t))

(defun wiki-add-br ()
  "Add a line break."
  (interactive "*")
  (wiki-add-markup-internal "\\\\\n"))

(defun wiki-add-hr ()
  "Add a horizontal line."
  (interactive "*")
  (wiki-add-markup-internal "---\n"))

;;; ------------------------ Link Commands ------------------------------

(defun wiki-add-link (link &optional arg)
  "Add a link."
  (interactive 
   (progn
     (if current-prefix-arg (setq link "")
       (setq link (read-from-minibuffer "Link to: " nil nil nil nil)))
     (list link current-prefix-arg)))
  (wiki-add-link-internal "" link nil current-prefix-arg))

(defun wiki-add-wiki-link (link title &optional arg)
  "Add a link to an external wiki site with title."
  (interactive "*sLink to: \nsTitle: \nP")
  (wiki-add-link-internal "wiki://" link title arg))

(defun wiki-add-http-link (link title &optional arg)
  "Add an external http link with title."
  (interactive "*sLink to: \nsTitle: \nP")
  (wiki-add-link-internal "http://" link title arg))

(defun wiki-add-image-link (image title &optional arg)
  "Add an image link with title."
  (interactive "sImage URL: \nsTitle: ")
  (wiki-add-link-internal "image:" image title arg))

(defun wiki-add-mailto-link (mailto title &optional arg)
  "Add a mailto link with title."
  (interactive "sEmail address: \nsTitle: ")
  (wiki-add-link-internal "mailto:" mailto title arg))

(defun wiki-add-doc-link (link &optional arg)
  "Add a link."
  (interactive 
   (progn
     (if current-prefix-arg (setq link "")
       (setq link (read-from-minibuffer "Link to: " nil nil nil nil)))
     (list link current-prefix-arg)))
  (wiki-add-link-internal "doc:" link nil current-prefix-arg))


;;; --------------------------- List Commands -------------------------------

(defun wiki-add-list-item ()
  "Add an unnumbered list item at the beginning of a line."
  (interactive "*")
  (if (not (bolp)) (insert "\n"))
  (insert "	* "))

(defun wiki-add-numbered-list-item ()
  "Add a numbered list item at the beginning of a line."
  (interactive "*")
  (if (not (bolp)) (insert "\n"))
  (insert "1. "))

(defun wiki-add-term-definition (term definition)
  "Add a term-defiition item at the beginning of a line."
  (interactive "sTerm: \nsDefinition: ")
  (if (not (bolp)) (insert "\n"))
  (insert term ":	" definition))

;;; ------------------------ Table Commands ------------------------
(defun wiki-add-table (&optional arg)
  "Add a table formatting directive to buffer leaving point inside.
If called with a PREFIX argument surround region with table."
  (interactive "*P")
  (wiki-add-tag-internal "||===" "" arg t))

(defun wiki-add-table-row ()
  "Add a table row."
  (interactive "*")
  (insert "||---"))

(defun wiki-add-table-data ()
  "Add a table data directive to buffer."
  (interactive "*")
  (insert "||"))


;;; ------------------------ INTERNAL FUNCTIONS ------------------------------

(defun wiki-add-tag-internal (tag space arg &optional area )
  "Add an WIKI TAG to document leaving point within.
If ARG is non-nil surround region with beginning and ending TAG.
If optional AREA is non-nil insert extra newlines.
If optional SPACE is non-nil insert extra space"
  (if arg
      (let ((start (min (mark) (point)))
            (end   (max (mark) (point))))
        (save-excursion
          ;; use trick since the first (insert) changes location of end
          (goto-char end)
          (save-excursion
            (goto-char start)
	    (insert tag space)
            (if area (insert "\n")))
          (if (string= tag "<<<")
	      (insert "\n>>>")
	    (if area
		(insert space "\n" tag)
	      (insert space tag)))
          (if area (insert "\n"))))
    (insert tag space)
    (if area (insert "\n"))
    (save-excursion
      (if (string= tag "<<<")
	  (insert "\n>>>")
	(if area
	    (insert space "\n" tag)
	  (insert space tag)))
      (if area (insert "\n")))))

(defun wiki-add-list-internal (type)
  "Insert begin/end pair of a TYPE of list and create an initial element.  
Single argument TYPE is a string, assumed to be a valid WIKI list type"
  (insert type)
  ;; Point goes right there.
  (save-excursion
    (insert "\ntype\n")))

(defun wiki-add-markup-internal (markup &optional newline)
  "Add a markup."
  (interactive "*")
  (insert markup (if newline "\n" "")))

(defun wiki-add-link-internal (type tag title &optional arg)
  "Add a some form of anchor."
  (if arg
      (let ((start (min (mark) (point)))
            (end   (max (mark) (point))))
        (save-excursion
          (goto-char end)
          (save-excursion
            (goto-char start)
            (insert "[[" type tag)
	    (if title (insert " " title)))
	    (insert "]]")))
    (progn
      (insert "[[" type tag)
      (if title (insert " " title))
      (save-excursion
        (insert "]]")))))

;;; -------------------------- FSF menubar setup ---------------------------

(condition-case nil
    (progn
      (define-key wiki-mode-map [menu-bar]
        (make-sparse-keymap "wiki-menu-bar"))
      (define-key wiki-mode-map [menu-bar Tables]
        (cons "Tables" (make-sparse-keymap "Tables")))
      (define-key wiki-mode-map [menu-bar Lists]
        (cons "Lists" (make-sparse-keymap "Lists")))
      (define-key wiki-mode-map [menu-bar Links]
        (cons "Links" (make-sparse-keymap "Links")))
      (define-key wiki-mode-map [menu-bar Wiki]
        (cons "Wiki" (make-sparse-keymap "Wiki")))

      (defvar wiki-list-map (make-sparse-keymap "WIKI Lists"))

      (define-key wiki-mode-map [menu-bar Wiki wiki-add-hr]
        '("Horizontal Line" . wiki-add-hr))
      (define-key wiki-mode-map [menu-bar Wiki wiki-add-br]
        '("Line Break" . wiki-add-br))
      (define-key wiki-mode-map [menu-bar Wiki separator-2]
        '("--"))
      (define-key wiki-mode-map [menu-bar Wiki wiki-add-preformatted]
        '("Preformatted" . wiki-add-preformatted))
      (define-key wiki-mode-map [menu-bar Wiki separator-3]
        '("--"))
      (define-key wiki-mode-map [menu-bar Wiki wiki-add-italics]
        '("Italics" . wiki-add-italics))
      (define-key wiki-mode-map [menu-bar Wiki wiki-add-bold]
        '("Bold" . wiki-add-bold))
      (define-key wiki-mode-map [menu-bar Wiki wiki-add-code]
        '("Code" . wiki-add-code))
      (define-key wiki-mode-map [menu-bar Wiki separator-4]
        '("--"))
      (define-key wiki-mode-map [menu-bar Wiki wiki-header-map]
        '("Heading" . wiki-header-map))

      (define-key wiki-mode-map [menu-bar Links wiki-add-image-link]
        '("Inlined Image" . wiki-add-image-link))
      (define-key wiki-mode-map [menu-bar Links wiki-add-mailto-link]
        '("Mail Link" . wiki-add-mailto-link))
      (define-key wiki-mode-map [menu-bar Links wiki-add-doc-link]
        '("Documentation Link" . wiki-add-doc-link))
      (define-key wiki-mode-map [menu-bar Links wiki-add-wiki-link]
        '("External Wiki Link" . wiki-add-wiki-link))
      (define-key wiki-mode-map [menu-bar Links wiki-add-http-link]
        '("External HTTP Link" . wiki-add-http-link))
      (define-key wiki-mode-map [menu-bar Links wiki-add-link]
        '("Internal Link" . wiki-add-link))

      (define-key wiki-mode-map [menu-bar Lists wiki-add-term-definition]
        '("Term-definition Item" . wiki-add-term-definition))
      (define-key wiki-mode-map [menu-bar Lists wiki-add-numbered-list-item]
        '("Numbered List Item" . wiki-add-numbered-list-item))
      (define-key wiki-mode-map [menu-bar Lists wiki-add-list-item]
        '("Unordered List Item" . wiki-add-list-item))

      (define-key wiki-mode-map [menu-bar Tables wiki-add-table-row]
        '("Row" . wiki-add-table-row))
      (define-key wiki-mode-map [menu-bar Tables wiki-add-table-data]
        '("Data" . wiki-add-table-data))
      (define-key wiki-mode-map [menu-bar Tables wiki-add-table]
        '("Table" . wiki-add-table))

      (defvar wiki-header-map (make-sparse-keymap "Header Size"))
      (define-key wiki-header-map "4" '("4" . wiki-add-header-4))
      (define-key wiki-header-map "3" '("3" . wiki-add-header-3))
      (define-key wiki-header-map "2" '("2" . wiki-add-header-2))
      (define-key wiki-header-map "1" '("1" . wiki-add-header-1))
      (fset 'wiki-header-map (symbol-value 'wiki-header-map))
      
      t)
  (error nil))

(provide 'wiki-mode)

;;; wiki-mode.el ends here
