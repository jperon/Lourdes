%Cible:sanctepie:
\version "2.12.3"

\header{
        title = ""
        tagline = ""
}

%\paper {
%	 paper-width = 42.0\cm
%	 line-width = 38\cm
%	 paper-height = 29.7\cm
%	 top-margin = 6\cm
%	 make-footer=##f
%}%


Soprano = \relative c'' {
	c4 b a g
	a8. a16 e2 e8. e16
	a2 a4 g
	c2 d
	e2 a,
	d2 g,4 c
	c2( b)
	c1
}

Alto = \relative c'' {
	c4 b a g
	a8. a16 e2 e8. e16
	e2 e4 b
	e2 g
	g2 a
	g2 e4 g
	g2( g)
	g1
}

Tenor = \relative c {
	r1
	r2 r4 e8. e16
	c'2 c4 d
	g,2 b
	c2 a
	b2 c4 e
	d2( f)
	e1
}

Tenorb = \relative c {
       r1
       r2 r4 
       e8. e16
       a4. b8 c4 d
       e4 d8 c d2
       e2 f
       g2 g4 g
       g1
       g1
}

Basse = \relative c {
	r1
	r2 r4 e8. e16
	a,2 a4 g
	c4 e d2
	c2 f
	g2 c,8[ d] e[ f]
	g2( <g g,>)
	c,1
}

Paroles = \lyricmode {
	San -- cte Pi -- e Dé -- ci -- me,
	glo -- ri -- ó -- se pa -- tró -- ne,
	O -- ra, o -- ra pro no -- bis.
}


#(define (rest-score r)
  (let ((score 0)
	(yoff (ly:grob-property-data r 'Y-offset))
	(sp (ly:grob-property-data r 'staff-position)))
    (if (number? yoff)
	(set! score (+ score 2))
	(if (eq? yoff 'calculation-in-progress)
	    (set! score (- score 3))))
    (and (number? sp)
	 (<= 0 2 sp)
	 (set! score (+ score 2))
	 (set! score (- score (abs (- 1 sp)))))
    score))

#(define has-one-or-less (lambda (lst) (or (null? lst) (null? (cdr lst)))))
#(define has-at-least-two (lambda (lst) (not (has-one-or-less lst))))
#(define (all-equal lst pred)
(or (has-one-or-less lst)
(and (pred (car lst) (cadr lst)) (all-equal (cdr lst) pred))))
#(define merge-rests-engraver
(lambda (context)
(let ((rest-same-length
(lambda (rest-a rest-b)
(eq? (ly:grob-property rest-a 'duration-log)
(ly:grob-property rest-b 'duration-log))))
(rests '()))
`((start-translation-timestep . ,(lambda (trans)
(set! rests '())))
(stop-translation-timestep . ,(lambda (trans)
(if (and (has-at-least-two
rests) (all-equal rests rest-same-length))
(for-each
(lambda (rest)
(ly:grob-set-property! rest 'Y-offset 0))
rests))))
(acknowledgers
(rest-interface . ,(lambda (engraver grob source-engraver)
(if (eq? 'Rest (assoc-ref
(ly:grob-property grob 'meta) 'name))
(set! rests (cons grob rests))))))))))
#(define merge-mmrests-engraver
(lambda (context)
(let* ((mmrest-same-length
(lambda (rest-a rest-b)
(eq? (ly:grob-property rest-a 'measure-count)
(ly:grob-property rest-b 'measure-count))))
(merge-mmrests
(lambda (rests)
(if (all-equal rests mmrest-same-length)
(let ((offset (if (eq? (ly:grob-property (car rests)
'measure-count) 1) 1 0)))
(for-each
(lambda (rest) (ly:grob-set-property! rest
'Y-offset offset))
rests)))))
(curr-rests '())
(rests '()))
`((start-translation-timestep . ,(lambda (trans)
(set! curr-rests '())))
(stop-translation-timestep . ,(lambda (trans)
(if (has-at-least-two curr-rests)
(set! rests (cons curr-rests rests)))))
(finalize . ,(lambda (translator)
(for-each merge-mmrests rests)))
(acknowledgers
(rest-interface . ,(lambda (engraver grob source-engraver)
(if (eq? 'MultiMeasureRest (assoc-ref
(ly:grob-property grob 'meta) 'name))
(set! curr-rests (cons grob curr-rests))))))))))

%\book{
%	#(set-global-staff-size 40)
	\score {
		\new ChoirStaff
	        <<
		\new Staff {
		\tempo 2 = 40
		\override Score . LyricText #'font-name = #"Linux Libertine O"
		\override Score . LyricText #'font-size = #3
			<<
			\set Staff.midiInstrument = "flute"
                        \set Staff.autoBeaming = ##f
			\clef treble
			\key c\major
			{
				\new Voice = "soprano" {
					\voiceOne
					\repeat volta 2 {\Soprano}
					\Soprano \bar "|."
				}
			}
			\new Voice = "alto" {
				\voiceTwo
				\repeat volta 2 {\Alto}
				\Alto
			}
			>>
		}
		\new Lyrics \lyricsto soprano {
			\Paroles
			\Paroles
		}
		\new Staff {
			<<
			\set Staff.midiInstrument = "flute"
		        \set Staff.autoBeaming = ##f
			\clef bass
			\key c\major
			\new Voice = "tenor" {
				\voiceOne
				\repeat volta 2 {\Tenor}
				\set Staff.aDueText = #""
				\partcombine
				{\voiceOne\Tenor}
				{\voiceThree\Tenorb}
			}
			\new Voice = "basse" {
			        \voiceTwo
				\repeat volta 2 {\Basse}
				\Basse
			}
			>>
		}
		>>
		\layout{
		  \context { \Staff \consists #merge-rests-engraver }
                  \context { \Staff \consists #merge-mmrests-engraver }
		  \context {
		    \Staff \RemoveEmptyStaves
		    \override VerticalAxisGroup #'remove-first = ##t
		  }
		}
		\midi{}
	}
%}

% \book{
	% #(set-global-staff-size 47)
	% \score {
		% 
		% <<
		% \new Staff {
			% <<
			% \set Staff.midiInstrument = "flute"
			% \clef treble
			% \key g\major
			% \time 3/4
			% \tempo 4=65
			% \new Voice = "soprano" {
				% \voiceOne
				% \Soprano
			% }          
			% \new Voice = "alto" {
				% \voiceTwo
				% \Alto
			% }
			% \new Lyrics \lyricsto soprano {
				% \Paroles
			% }
			% >>
		% }
		% >>
		% 
		% \layout{}
		% \midi{}
	% }
% }

