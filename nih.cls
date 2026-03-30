% vim:tabstop=4 expandtab syntax=tex:
%
% nih.cls - class for preparing NIH (US National Institutes of Health)
% grant applications.
% 
% Copyright (C) 2003, 2004, 2005, 2006 Bruce Donald.
% 
% This work may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3c
% of this license or (at your option) any later version.
% The latest version of this license is in
%   http://www.latex-project.org/lppl.txt
% and version 1.3 or later is part of all distributions of LaTeX
% version 2003/12/01 or later.
%
% This work has the LPPL maintenance status "author-maintained".
% 
% The Current Maintainer of this work is Bruce Donald
% (http://www.cs.duke.edu/brd/).
%
% This work consists of only this one file, nih.cls.
% Accompanying example files are not under the LPPL.
%
% last changed by Bruce Donald in 2005
% to mimic the two PHS forms.
%
% Previous modified by Alan Shields, May 2003
% email: Alan-Shields2omrf.ouhsc.edu
% Heavily based upon (read: copied almost exactly from)
%    nih.sty by Bruce R. Donald and Matthew L. Fidler
%
\NeedsTeXFormat{LaTeX2e}
%\ProvidesClass{nih}[2005 NIH PHS 398 as of June 2005]
\ProvidesClass{nih}[2005/06/01 NIH PHS 398 as of June 2005]

% includes needed for preliminary code
\RequirePackage{ifthen}

% Preliminary code
\newcommand{\nih@kk}{~}

\newboolean{nih@blank}
%uncomment the first line if you want headers/foot (424 says not allowed)
%\setboolean{nih@blank}{false}
\setboolean{nih@blank}{true}

% Options
%%%% Changed by M A Lewis, Ph.D. (mal11 at alumni.cwru.edu)
%%%% NIH suggests Helvetica or Arial 12pt. Use Helvetica Postscript fonts for 12pt also.
\DeclareOption{12pt}{\AtEndOfClass{\RequirePackage{helvet}\renewcommand{\familydefault}{\sfdefault}}}
%\DeclareOption{12pt}{\AtEndOfClass{\RequirePackage{times}}}
%\DeclareOption{12pt}{\AtEndOfClass{\RequirePackage{arial}}}
\DeclareOption{11pt}{\AtEndOfClass{\RequirePackage{helvet}\renewcommand{\familydefault}{\sfdefault}}}
\DeclareOption{nihblank}{\setboolean{nih@blank}{true}}
\DeclareOption{kk}{\renewcommand{\nih@kk}{\small KK}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

% The class we're overwriting
\LoadClassWithOptions{article}


% Begin Requirements
%%%% Changed by M A Lewis, Ph.D. (mal11 at alumni.cwru.edu)
%%%% PHS 398 allows 0.5in magins everywhere. Simplify page layout using geometry package.
%\RequirePackage{fullpage}

%comment out to get rid of head/foot
%\RequirePackage[letterpaper,margin=0.5in]{geometry}
\RequirePackage[letterpaper,margin=0.75in, includehead]{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{amsmath}

%%%% More code
% preamble stuff
%uncomment the first line if you want PI information
%\newcommand{\nih@PIname}{Blackstone, Ishwaran, Li}
\newcommand{\nih@PIname}{}
\newcommand{\piname}[1]{\renewcommand{\nih@PIname}{#1}}

% constants
\newcommand{\nih@sillysize}{\scriptsize}

% set the page style
\pagestyle{fancy}
\chead{\fancyplain{}{%
        \ifthenelse{\boolean{nih@blank}}%
            {}% fi
            {%
                {{\sf\scriptsize Principal Investigator/Program Director%
                    (Last, First, Middle):}}%
            }% esle
    }
}
\rhead{\fancyplain{}{%
        \ifthenelse{\boolean{nih@blank}}%
            {\ \ \ {\nih@PIname}\ \ \ \ \ }% fi
            {%
                \underline{\ \ \ {\nih@PIname}\ \ \ \ \ }%
            }% esle
    }
}
\lhead{\fancyplain{}{\nih@kk}}
\lfoot{\fancyplain{}{%
        \ifthenelse{\boolean{nih@blank}}%
            {}% fi
            {\sf\footnotesize PHS 398/2590 (Rev.~09/04, Reissued 4/2006)\\}% esle
    }
}
\cfoot{\ifthenelse{\boolean{nih@blank}}%
        {\thepage}% fi
        {\sf\footnotesize{Page}}% esle
    \ \underline{\ \ \ {\sf\thepage}\ \ \ }%
}
%comment out if you don't want page numbers
\cfoot{\thepage}
%\cfoot{}
%comment out if you don't want a footer line
%\renewcommand{\footrulewidth}{0.75pt}
\rfoot{\fancyplain{}%
    {\sf\footnotesize{\textbf{Continuation Format Page}}}%
}
%comment out if you want fancy footers
\rfoot{}
%\renewcommand{\headrulewidth}{0pt}


%%%% Changed by M A Lewis, Ph.D. (mal11 at alumni.cwru.edu)
%%%% Simplify page layout by using geometry package above.
% page dimensions (note: assumes 8.5x11)
%\setlength{\oddsidemargin}{31pt}
%\setlength{\textwidth}{8.5in}
%\addtolength{\textheight}{0in} % 0.5in margins on both sides
%\addtolength{\textwidth}{-1.1in}
%\setlength{\oddsidemargin}{-1in}
%\addtolength{\oddsidemargin}{0.505in}
%\setlength{\evensidemargin}{\oddsidemargin}
%\addtolength{\textheight}{0.2in}
%\addtolength{\topmargin}{-0.2in}
%\renewcommand{\baselinestretch}{.9}
%\headwidth=\textwidth

%\addtolength{\headheight}{-0.2in}

% rename the bibliography section
\AtBeginDocument{\renewcommand{\refname}{Publications}}
%FIXME: something is going on with the bibliography style. Dunno what.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This was lifted from the res.cls
%% JE.
%%
%   \name{text} defines your name
%
%   \address{text}
%		defines your address
%		this can be called twice if you have two addresses
%		use \\'s to indicate where either line breaks or
%		comas should go
%
% prints a centered name with the address centered
% or the two address on opposite sides of the page
%
\def\printcentername{\begingroup
 \leftskip=-\hoffset	     % I use leftskip to move things to the left as
  \advance\textwidth\hoffset % changing hoffset doesn't work. But this
  \hsize=\textwidth	     % doesn't really work as hboxes are rules
			     % are unaffected
  \let\par=\@@par
  \parindent=0pt
  \parskip=0pt
  % print the name centered
  % \leavevmode\hbox to \textwidth{\hfil\@tablebox{\namefont\@name}\hfil}\par
  \@ifundefined{@addressone}{%
    % do nothing
  }{%
    \@ifundefined{@addresstwo}{
      % only one address
      \leavevmode\hbox to \textwidth{\hfil\@tablebox{\@addressone}\hfil}\par
    }{
      % two addresses
      \leavevmode\hbox to \textwidth{\@tablebox{\@addressone}\hfil
				     \@tablebox{\@addresstwo}}\par
    }%
  }%
\endgroup}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is used to print the name and address at the top of
% the page with a hline in between
%
\def\namefont{\large\bf}
\def\@linename{\begingroup
  \def\\{, }
  {\namefont\@name}
  \vskip 2pt
  \fullline
  \vskip 2pt
  % where do you live?
  \@ifundefined{@addressone}{%
    % do nothing
  }{%
    \leavevmode\hbox to \textwidth
      {\hfill\vbox{\hbox{\@addressone}
		   \hbox{\@addresstwo}
		  }%
      }\par
  }
\endgroup}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create a multiline box.
%
\def\@tablebox#1{\begin{tabular}[t]{@{}l@{\extracolsep{\fill}}}#1\end{tabular}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use this to define your name
%
\def\name#1{\def\@name{#1}}

\def\@name{}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use this to define your address, this may be called more than once.
%
\let\@addressone\relax
\let\@addresstwo\relax

\def\address#1{
  \@ifundefined{@addressone}{\def\@addressone{#1}}{\def\@addresstwo{#1}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if you want to print your name and address is a slightly
% different format than sugested, then this can be used
% to place it exactly where you want
%
\def\opening{\def\@opening{}
  \begingroup
  \leftskip=-\hoffset	     % I use leftskip to move things to the left as
  \advance\textwidth\hoffset % changing hoffset doesn't work. But this
  \hsize=\textwidth	     % doesn't really work as hboxes are rules
			     % are unaffected
  \let\par=\@@par
  \parindent=0pt
  \parskip=0pt
  \print@name
  \endgroup
}