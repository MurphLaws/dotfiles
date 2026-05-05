; extends

; Only capture the FIRST paragraph_segment (the bullet line), not continuation lines.
; The `.` anchor matches the first child of the parent.

(unordered_list1
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.unordered.1.content))

(unordered_list2
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.unordered.2.content))

(unordered_list3
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.unordered.3.content))

(unordered_list4
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.unordered.4.content))

(unordered_list5
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.unordered.5.content))

(unordered_list6
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.unordered.6.content))

(ordered_list1
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.ordered.1.content))

(ordered_list2
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.ordered.2.content))

(ordered_list3
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.ordered.3.content))

(ordered_list4
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.ordered.4.content))

(ordered_list5
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.ordered.5.content))

(ordered_list6
  content: (paragraph
    .
    (paragraph_segment) @neorg.lists.ordered.6.content))
