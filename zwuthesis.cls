%
% Copyright (C) 2015-2023 by zwu TeX Users Group <https://github.com/zwutug>
%
% This file may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3c
% of this license or (at your option) any later version.
% The latest version of this license is in
%    https://www.latex-project.org/lppl.txt
% and version 1.3c or later is part of all distributions of LaTeX
% version 2008 or later.
%

\NeedsTeXFormat{LaTeX2e}[2017/04/15]
\ProvidesClass{zwuthesis}[zwu thesis template]

% 报错和警告
\newcommand\zwu@error[1]{%
  \ClassError{zwuthesis}{#1}{}%
}
\newcommand\zwu@warning[1]{%
  \ClassWarning{zwuthesis}{#1}%
}

% 检查 \LaTeXe{} kernel 版本
\@ifl@t@r\fmtversion{2017/04/15}{}{
  \zwu@error{%
    TeX Live 2017 or later version is required to compile this document%
  }
}

% 检查编译引擎，要求使用 XeLaTeX 或 LuaLaTeX。
\RequirePackage{iftex}
\ifXeTeX\else
  \ifLuaTeX\else
    \zwu@error{XeLaTeX or LuaLaTeX is required to compile this document}
  \fi
\fi


% \subsection{处理选项}

\RequirePackage{kvdefinekeys}
\RequirePackage{kvsetkeys}
\RequirePackage{kvoptions}

% 提供一个 \cs{zwusetup} 命令支持 \emph{key-value} 的方式来设置。
\let\zwu@setup@hook\@empty
\newcommand\zwusetup[1]{%
  \let\zwu@setup@hook\@empty
  \kvsetkeys{zwu}{#1}%
  \zwu@setup@hook
}

% 同时用 \emph{key-value} 的方式来定义这些接口：
% \begin{latex}
%   \zwu@define@key{
%     <key> = {
%       name = <name>,
%       choices = {
%         <choice1>,
%         <choice2>,
%       },
%       default = <default>,
%       code = <code>,
%     },
%   }
% \end{latex}

% 其中 |choices| 设置允许使用的值，默认为第一个（或者 \meta{default}）；
% \meta{code} 是相应的内容被设置时执行的代码。

\newcommand\zwu@define@key[1]{%
  \kvsetkeys{zwu@key}{#1}%
}
\kv@set@family@handler{zwu@key}{%
%
% \cs{zwusetup} 会将 \meta{value} 存到 \cs{zwu@\meta{key}}，
% 但是宏的名字包含 “-” 这样的特殊字符时不方便直接调用，比如 |key = math-style|，
% 这时可以用 |name| 设置 \meta{key} 的别称，比如 |key = math@style|，
% 这样就可以通过 \cs{zwu@math@style} 来引用。
% |default| 是定义该 \meta{key} 时默认的值，缺省为空。
%
  \@namedef{zwu@#1@@name}{#1}%
  \def\zwu@@default{}%
  \def\zwu@@choices{}%
  \kv@define@key{zwu@value}{name}{%
    \@namedef{zwu@#1@@name}{##1}%
  }%
  %
  % 由于在定义接口时，\cs{zwu@\meta{key}@@code} 不一定有定义，
  % 而且在文档类/宏包中还有可能对该 |key| 的 |code| 进行添加。
  % 所以 \cs{zwu@\meta{key}@@code} 会检查如果在定义文档类/宏包时则推迟执行，否则立即执行。
  %
  \@namedef{zwu@#1@@check}{}%
  \@namedef{zwu@#1@@code}{}%
  %
  % 保存下 |choices = {}| 定义的内容，在定义 \cs{zwu@\meta{name}} 后再执行。
  %
  \kv@define@key{zwu@value}{choices}{%
    \def\zwu@@choices{##1}%
    \@namedef{zwu@#1@@reset}{}%
    %
    % \cs{zwu@\meta{key}@check} 检查 |value| 是否有效，
    % 并设置 \cs{ifzwu@\meta{name}@\meta{value}}。
    %
    \@namedef{zwu@#1@@check}{%
      \@ifundefined{%
        ifzwu@\@nameuse{zwu@#1@@name}@\@nameuse{zwu@\@nameuse{zwu@#1@@name}}%
      }{%
        \zwu@error{Invalid value "#1 = \@nameuse{zwu@\@nameuse{zwu@#1@@name}}"}%
      }%
      \@nameuse{zwu@#1@@reset}%
      \@nameuse{zwu@\@nameuse{zwu@#1@@name}@\@nameuse{zwu@\@nameuse{zwu@#1@@name}}true}%
    }%
  }%
  \kv@define@key{zwu@value}{default}{%
    \def\zwu@@default{##1}%
  }%
  \kvsetkeys{zwu@value}{#2}%
  \@namedef{zwu@\@nameuse{zwu@#1@@name}}{}%
  %
  % 第一个 \meta{choice} 设为 \meta{default}，
  % 并且对每个 \meta{choice} 定义 \cs{ifzwu@\meta{name}@\meta{choice}}。
  %
  \kv@set@family@handler{zwu@choice}{%
    \ifx\zwu@@default\@empty
      \def\zwu@@default{##1}%
    \fi
    \expandafter\newif\csname ifzwu@\@nameuse{zwu@#1@@name}@##1\endcsname
    \expandafter\g@addto@macro\csname zwu@#1@@reset\endcsname{%
      \@nameuse{zwu@\@nameuse{zwu@#1@@name}@##1false}%
    }%
  }%
  \kvsetkeys@expandafter{zwu@choice}{\zwu@@choices}%
  %
  % 将 \meta{default} 赋值到 \cs{zwu@\meta{name}}，如果非空则执行相应的代码。
  %
  \expandafter\let\csname zwu@\@nameuse{zwu@#1@@name}\endcsname\zwu@@default
  \expandafter\ifx\csname zwu@\@nameuse{zwu@#1@@name}\endcsname\@empty\else
    \@nameuse{zwu@#1@@check}%
  \fi
  %
  % 定义 \cs{zwusetup} 接口。
  %
  \kv@define@key{zwu}{#1}{%
    \@namedef{zwu@\@nameuse{zwu@#1@@name}}{##1}%
    \@nameuse{zwu@#1@@check}%
    \@nameuse{zwu@#1@@code}%
  }%
}

% 定义接口向 |key| 添加 |code|：

\newcommand\zwu@option@hook[2]{%
  \expandafter\g@addto@macro\csname zwu@#1@@code\endcsname{#2}%
}

\zwu@define@key{
  degree = {
    choices = {
      bachelor,
    },
    default = bachelor,
  },
  main-language = {
    name = main@language,
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  language = {
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  system = {
    choices = {
      auto,
      mac,
      unix,
      windows,
    },
    default = auto,
  },
  fontset = {
    choices = {
      auto,
      windows,
      mac,
      ubuntu,
      fandol,
      none,
    },
    default = auto,
  },
  font = {
    choices = {
      auto,
      times,
      termes,
      stix,
      xits,
      libertinus,
      newcm,
      lm,
      newtx,
      none,
    },
    default = auto,
  },
  cjk-font = {
    name = cjk@font,
    choices = {
      auto,
      windows,
      mac,
      noto,
      fandol,
      none,
    },
    default = auto,
  },
  math-font = {
    name = math@font,
    choices = {
      auto,
      stix,
      xits,
      libertinus,
      newcm,
      cm,
      lm,
      newtx,
      none,
    },
    default = auto,
  },
  math-style = {
    name = math@style,
    choices = {
      GB,
      ISO,
      TeX,
    },
  },
  uppercase-greek = {
    name = uppercase@greek,
    choices = {
      italic,
      upright,
    },
  },
  less-than-or-equal = {
    name = leq,
    choices = {
      slanted,
      horizontal,
    },
  },
  integral = {
    choices = {
      upright,
      slanted,
    },
  },
  integral-limits = {
    name = integral@limits,
    choices = {
      true,
      false,
    },
  },
  partial = {
    choices = {
      upright,
      italic,
    },
  },
  math-ellipsis = {
    name = math@ellipsis,
    choices = {
      centered,
      lower,
      AMS,
    },
  },
  real-part = {
    name = real@part,
    choices = {
      roman,
      fraktur,
    },
  },
  cite-style = {
    name = cite@style,
    choices = {
      super,
      inline,
      authoryear,
    },
  },
  output = {
    choices = {
      print,
      electronic,
    },
    default = electronic,
  },
  section-style = {
    name = section@style,
    choices = {
      chinese,
      arabic,
    },
    default = chinese,
  },
  badge-color = {
    name = badge@color,
    choices = {
      blue,
      black,
    },
    default = blue,
  },
  reviewer = {
    choices = {
      true,
      false,
    },
    default = false,
  },
}

% 将 \zwu@cite@style 置空方便后续进行判断。
\def\zwu@cite@style{}

\newif\ifzwu@degree@graduate
\newcommand\zwu@set@graduate{%
  \ifzwu@degree@bachelor
    \zwu@degree@graduatefalse
  \else
    \zwu@degree@graduatetrue
  \fi
}
\zwu@set@graduate
\zwu@option@hook{degree}{%
  \zwu@set@graduate
}

% 使用 \pkg{kvoptions} 提供的 key-value 接口，
\SetupKeyvalOptions{
  family  = zwu,
  prefix  = zwu@,
  setkeys = \kvsetkeys,
}

% 设置默认 \option{openany}。
\DeclareBoolOption[false]{openright}
\DeclareComplementaryOption{openany}{openright}

% 兼容旧版本的文档类选项。
% Reserved for compatibility until 2020-07-01.
\DeclareVoidOption{doctor}{\zwusetup{degree=doctor}}
\DeclareVoidOption{master}{\zwusetup{degree=master}}
\DeclareVoidOption{bachelor}{\zwusetup{degree=bachelor}}
\DeclareVoidOption{chinese}{\zwusetup{language=chinese}}
\DeclareVoidOption{english}{\zwusetup{language=english}}
\DeclareVoidOption{academic}{\zwusetup{degree-type=academic}}
\DeclareVoidOption{professional}{\zwusetup{degree-type=professional}}
\DeclareVoidOption{print}{\zwusetup{output=print}}
\DeclareVoidOption{pdf}{\zwusetup{output=electronic}}
\newif\ifzwu@legacy@cite@style
\DeclareVoidOption{super}{\zwusetup{cite-style=super}\zwu@legacy@cite@styletrue}
\DeclareVoidOption{numbers}{\zwusetup{cite-style=inline}\zwu@legacy@cite@styletrue}
\DeclareVoidOption{authoryear}{\zwusetup{cite-style=authoryear}\zwu@legacy@cite@styletrue}
\DeclareVoidOption{arabic}{\zwusetup{section-style=arabic}}
\DeclareVoidOption{colorlogo}{\zwusetup{badge-color=blue}}
\DeclareVoidOption{bwlogo}{\zwusetup{badge-color=black}}

% 载入 \cls{ctexbook}。
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{ctexbook}}
\ProcessKeyvalOptions*

% \subsection{加载文档类和宏包}

\ifzwu@openright
  \PassOptionsToClass{openright}{book}
\else
  \PassOptionsToClass{openany}{book}
\fi

\ifzwu@output@electronic
  \PassOptionsToClass{oneside}{book}
\fi
\PassOptionsToPackage{no-math}{fontspec}

% 载入 \cls{ctexbook} 文档类，注意要求为 2.4.9 或更高的版本。
\LoadClass[UTF8,a4paper,scheme=plain,zihao=-4,fontset=none]{ctexbook}[2017/04/01]

% 建议在模板开始处载入全部宏包，不要轻易改变加载顺序。
% \pkg{hyperref} 一般在最后加载。
\RequirePackage{etoolbox}
\RequirePackage{amsmath}
\RequirePackage{fontspec}[2017/03/31]
\RequirePackage{geometry}
\RequirePackage{graphicx}
\RequirePackage{fancyhdr}
\RequirePackage{color}
\RequirePackage{titletoc}
\RequirePackage{caption}
\RequirePackage[perpage]{footmisc}
\RequirePackage{url}
\RequirePackage{notoccite}
\RequirePackage{multirow}

% 如果用户在导言区未调用 \pkg{biblatex}，则自动调用 \pkg{natbib}。
\AtEndPreamble{
  \@ifpackageloaded{biblatex}{}{
    \RequirePackage{natbib}
  }
}

% 对冲突的宏包报错。
\RequirePackage{filehook}
\newcommand\zwu@package@conflict[2]{
  \AtEndOfPackageFile*{#1}{%
    \AtBeginOfPackageFile*{#2}{%
      \zwu@error{The "#2" package is incompatible with "#1"}%
    }%
  }%
}

\zwu@package@conflict{biblatex}{bibunits}
\zwu@package@conflict{biblatex}{chapterbib}
\zwu@package@conflict{biblatex}{cite}
\zwu@package@conflict{biblatex}{multibib}
\zwu@package@conflict{biblatex}{natbib}

\zwu@package@conflict{bibunits}{biblatex}
\zwu@package@conflict{bibunits}{chapterbib}
\zwu@package@conflict{bibunits}{multibib}

\zwu@package@conflict{unicode-math}{amscd}
\zwu@package@conflict{unicode-math}{amsfonts}
\zwu@package@conflict{unicode-math}{amssymb}
\zwu@package@conflict{unicode-math}{bbm}
\zwu@package@conflict{unicode-math}{bm}
\zwu@package@conflict{unicode-math}{eucal}
\zwu@package@conflict{unicode-math}{eufrak}
\zwu@package@conflict{unicode-math}{mathrsfs}
\zwu@package@conflict{unicode-math}{newtxmath}
\zwu@package@conflict{unicode-math}{upgreek}

\zwu@package@conflict{natbib}{biblatex}
\zwu@package@conflict{natbib}{cite}

\zwu@package@conflict{newtxmath}{amsfonts}
\zwu@package@conflict{newtxmath}{amssymb}
\zwu@package@conflict{newtxmath}{unicode-math}
\zwu@package@conflict{newtxmath}{upgreek}


% \pkg{amsthm} 需要在 \pkg{newtx} 前载入，参考 \pkg{newtx} 的文档。
\AtBeginOfPackageFile*{amsthm}{
  \@ifpackageloaded{newtxmath}{
    \zwu@error{The "amsthm" package should be loaded before setting "newtxmath"}
  }{}
}%



% \subsection{处理语言}

% 定义 \cs{zwu@main@language}，当在导言区修改 \option{language} 时，
% 保存为论文的主要语言；
% \cs{zwu@reset@main@language} 则用于正文中恢复为主要语言。
%    \begin{macrocode}
\zwusetup{main-language=\zwu@language}%
\let\zwu@main@language\zwu@language

\zwu@option@hook{language}{%
  \ifx\@begindocumenthook\@undefined\else
    \zwusetup{main-language=\zwu@language}%
    \let\zwu@main@language\zwu@language
  \fi
}
\newcommand\zwu@reset@main@language{%
  \zwusetup{language = \zwu@main@language}%
  \let\zwu@language\zwu@main@language
}

% 带圈数字和星号使用中文字体。
\ifLuaTeX
  % ctex 将带圈数字 U+2460–U+24FF 归入字符范围 3（ALchar），这里改回范围 6（JAchar）
  \ltjdefcharrange{3}{%
    "2000-"243F, "2500-"27BF, "2900-"29FF, "2B00-"2BFF}
  \ltjdefcharrange{6}{%
    "2460-"24FF, "2E80-"2EFF, "3000-"30FF, "3190-"319F, "31F0-"4DBF,
    "4E00-"9FFF, "F900-"FAFF, "FE10-"FE1F, "FE30-"FE6F, "FF00-"FFEF,
    "1B000-"1B16F, "1F100-"1F2FF, "20000-"3FFFF, "E0100-"E01EF}
\else
  \ifXeTeX
    \xeCJKDeclareCharClass{CJK}{"2460 -> "2473}
    \xeCJKDeclareCharClass{CJK}{"2605}
  \fi
\fi

% 由于 Unicode 的一些标点符号是中西文混用的：
% U+00B7、U+2013、U+2014、U+2018、U+2019、
% U+201C、U+201D、U+2025、U+2026、U+2E3A，
% 所以要根据语言设置正确的字体。
% https://github.com/CTeX-org/ctex-kit/issues/389
\newcommand\zwu@set@punctuations{%
  \ifzwu@language@chinese
    \ifLuaTeX
      \ltjsetparameter{jacharrange={+9}}
    \else
      \ifXeTeX
        \xeCJKDeclareCharClass{FullLeft}{"2018, "201C}%
        \xeCJKDeclareCharClass{FullRight}{
          "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A,
        }%
      \fi
    \fi
  \else
    \ifLuaTeX
      \ltjsetparameter{jacharrange={-9}}
    \else
      \ifXeTeX
        \xeCJKDeclareCharClass{HalfLeft}{"2018, "201C}%
        \xeCJKDeclareCharClass{HalfRight}{
          "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A,
        }%
      \fi
    \fi
  \fi
}
\zwu@set@punctuations
\zwu@option@hook{language}{\zwu@set@punctuations}

% 根据语言设置各章节的名称，只有在导言区设置 \option{language} 时会修改，
% 而在正文局部切换语言时则不变。

% 由于《撰写手册》中的“speciality”一词使用的是英式拼法，
% 所以“acknowledgements”也保持一致。
\newcommand\zwu@set@chapter@names{%
  \ifzwu@main@language@chinese
    \def\contentsname{目录}%
    \def\listfigurename{插图清单}%
    \def\listtablename{表格清单}%
    \ctexset{
      chapter/name   = {第,章},
    }%
    \def\bibname{参考文献}%
    \def\appendixname{附录}%
    \def\zwu@acknowledgements@name{致谢}%
    \def\zwu@publication@name{在读期间发表的学术论文与取得的研究成果}%
    \newcommand\zwu@notation@name{符号说明}%
  \else
    \def\contentsname{Contents}%
    \def\listfigurename{List of Figures}%
    \def\listtablename{List of Tables}%
    \ctexset{
      chapter/name   = {\chaptername\space},
    }%
    \def\bibname{Bibliography}%
    \def\appendixname{Appendix}%
    \def\zwu@acknowledgements@name{Acknowledgements}%
    \def\zwu@publication@name{Publications}%
    \def\zwu@notation@name{Notation}%
  \fi
}
\zwu@set@chapter@names
\zwu@option@hook{main-language}{\zwu@set@chapter@names}

% 这部分名称在正文中局部地修改语言时会发生变化。
\newcommand\zwu@set@names{%
  \ifzwu@language@chinese
    \def\figurename{图}%
    \def\tablename{表}%
  \else
    \def\figurename{Figure}%
    \def\tablename{Table}%
  \fi
}
\zwu@set@names
\zwu@option@hook{language}{\zwu@set@names}


% \subsection{字体}

% 字号

% 正文字号12bp，研究生行距20bp，本科生行距22bp；
% 其他命令的行距按照相同的的比例设置，如表~\ref{tab:fontsize}。
% \begin{table}[htb]
%   \centering
%   \caption{标准字体命令与字号、行距的对应}
%   \label{tab:fontsize}
%   \begin{tabular}{lllll}
%     \toprule
%     字体命令          & 字号 & bp   & 研究生行距 & 本科生行距 \\
%     \midrule
%     \cs{tiny}         & 小六 & 6.5  & 10.83      & 11.92      \\
%     \cs{scriptsize}   & 六号 & 7.5  & 12.5       & 13.75      \\
%     \cs{footnotesize} & 小五 & 9    & 15         & 16.5       \\
%     \cs{small}        & 五号 & 10.5 & 17.5       & 19.25      \\
%     \cs{normalsize}   & 小四 & 12   & 20         & 22         \\
%     \cs{large}        & 小三 & 15   & 25         & 27.5       \\
%     \cs{Large}        & 小二 & 18   & 30         & 33         \\
%     \cs{LARGE}        & 二号 & 22   & 36.67      & 40.33      \\
%     \cs{huge}         & 小一 & 24   & 40         & 44         \\
%     \cs{Huge}         & 一号 & 26   & 43.33      & 47.67      \\
%     \bottomrule
%   \end{tabular}
% \end{table}
%
% 注意重定义 \normalsize 应在 \pkg{unicode-math} 的 \cs{setmathfont} 前。
\newcommand\zwu@set@font@size{%
    \renewcommand\normalsize{%
      \@setfontsize\normalsize{12bp}{22bp}%
      \abovedisplayskip 12bp \@plus3bp \@minus7bp%
      \abovedisplayshortskip \z@ \@plus3bp%
      \belowdisplayshortskip 6.5bp \@plus3.5bp \@minus3bp%
      \belowdisplayskip \abovedisplayskip
      \let\@listi\@listI}%
  \normalsize
  \ifx\MakeRobust\@undefined \else
      \MakeRobust\normalsize
  \fi
}
\zwu@set@font@size
\zwu@option@hook{degree}{\zwu@set@font@size}

% 设置行距的倍数为 1。
\linespread{1}\selectfont


% 检测系统
\ifzwu@system@auto
  \IfFileExists{/System/Library/Fonts/Menlo.ttc}{
    \zwusetup{system = mac}
  }{
    \IfFileExists{/dev/null}{
      \IfFileExists{null:}{
        \zwusetup{system = windows}
      }{
        \zwusetup{system = unix}
      }
    }{
      \zwusetup{system = windows}
    }
  }
\fi

% 处理 \opt{fontset}
\ifzwu@fontset@auto
  \ifzwu@system@windows
    \zwusetup{fontset = windows}
  \else
    \ifzwu@system@mac
      \zwusetup{fontset = mac}
    \else
      \IfFontExistsTF{Noto Serif CJK SC}{
        \zwusetup{fontset = ubuntu}
      }{
        \zwusetup{fontset = fandol}
      }
    \fi
  \fi
\fi

% 《撰写手册》要求西文字体使用 Times New Roman 和 Arial，
% 但是在 Linux 下没有这两个字体，所以使用它们的克隆版 TeX Gyre Termes 和
% TeX Gyre Heros。
\ifzwu@font@auto
  \ifzwu@fontset@windows
    \zwusetup{font=times}
  \else
    \ifzwu@fontset@mac
      \zwusetup{font=times}
    \else
      \zwusetup{font=termes}
    \fi
  \fi
\fi

% Times New Roman + Arial
\newcommand\zwu@set@font@times{%
  \setmainfont{Times New Roman}%
  \setsansfont{Arial}%
  \ifzwu@system@mac
    \setmonofont{Menlo}[Scale = MatchLowercase]%
  \else
    \setmonofont{Courier New}[Scale = MatchLowercase]%
  \fi
}

% TeX Gyre Termes
\newcommand\zwu@set@font@termes{%
  \setmainfont{texgyretermes}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \zwu@set@texgyre@sans@mono
}

\newcommand\zwu@set@texgyre@sans@mono{%
  \setsansfont{texgyreheros}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setmonofont{texgyrecursor}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
    Scale          = MatchLowercase,
    Ligatures      = CommonOff,
  ]%
}

% STIX Two 字体。
% STIX 文件名在 v2.10 2020-12-19 从
% \file{STIX2Text-Regular.otf}、\file{STIX2Math.otf} 分别改为
% \file{STIXTwoText-Regular.otf}、\file{STIXTwoMath-Regular.otf}。
\let\zwu@font@family@stix\@empty
\newcommand\zwu@set@stix@names{%
  \ifx\zwu@font@family@stix\@empty
    \IfFontExistsTF{STIXTwoText-Regular.otf}{%
      \gdef\zwu@font@family@stix{STIXTwoText}%
      \gdef\zwu@font@name@stix@math{STIXTwoMath-Regular}%
    }{%
      \gdef\zwu@font@family@stix{STIX2Text}%
      \gdef\zwu@font@name@stix@math{STIX2Math}%
    }%
  \fi
}

\newcommand\zwu@set@font@stix{%
  \zwu@set@stix@names
  \setmainfont{\zwu@font@family@stix}[
    Extension      = .otf,
    UprightFont    = *-Regular,
    BoldFont       = *-Bold,
    ItalicFont     = *-Italic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \zwu@set@texgyre@sans@mono
}

% XITS 字体。
% XITS 的文件名在 v1.109 2018-09-30
% 从 \file{xits-regular.otf}、\file{xits-math.otf} 分别改为
% \file{XITS-Regular.otf}、\file{XITSMath-Regular.otf}。
\let\zwu@font@family@xits\@empty
\newcommand\zwu@set@xits@names{%
  \ifx\zwu@font@family@xits\@empty
    \IfFontExistsTF{XITSMath-Regular.otf}{%
      \gdef\zwu@font@family@xits{XITS}%
      \gdef\zwu@font@style@xits@rm{Regular}%
      \gdef\zwu@font@style@xits@bf{Bold}%
      \gdef\zwu@font@style@xits@it{Italic}%
      \gdef\zwu@font@style@xits@bfit{BoldItalic}%
      \gdef\zwu@font@name@xits@math{XITSMath-Regular}%
    }{%
      \gdef\zwu@font@family@xits{xits}%
      \gdef\zwu@font@style@xits@rm{regular}%
      \gdef\zwu@font@style@xits@bf{bold}%
      \gdef\zwu@font@style@xits@it{italic}%
      \gdef\zwu@font@style@xits@bfit{bolditalic}%
      \gdef\zwu@font@name@xits@math{xits-math}%
    }%
  \fi
}

\newcommand\zwu@set@font@xits{%
  \zwu@set@xits@names
  \setmainfont{\zwu@font@family@xits}[
    Extension      = .otf,
    UprightFont    = *-\zwu@font@style@xits@rm,
    BoldFont       = *-\zwu@font@style@xits@bf,
    ItalicFont     = *-\zwu@font@style@xits@it,
    BoldItalicFont = *-\zwu@font@style@xits@bfit,
  ]%
  \zwu@set@texgyre@sans@mono
}

% Libertinus 的文件名在 v6.7 2019-04-03 从小写改为驼峰式，
% 在大小写敏感的平台上需要进行判断。
\let\zwu@font@family@libertinus\@empty
\newcommand\zwu@set@libertinus@names{%
  \ifx\zwu@font@family@libertinus\@empty
    \IfFontExistsTF{LibertinusSerif-Regular.otf}{%
      \gdef\zwu@font@family@libertinus@serif{LibertinusSerif}%
      \gdef\zwu@font@family@libertinus@sans{LibertinusSans}%
      \gdef\zwu@font@name@libertinus@math{LibertinusMath-Regular}%
      \gdef\zwu@font@style@libertinus@rm{Regular}%
      \gdef\zwu@font@style@libertinus@bf{Bold}%
      \gdef\zwu@font@style@libertinus@it{Italic}%
      \gdef\zwu@font@style@libertinus@bfit{BoldItalic}%
    }{%
      \gdef\zwu@font@family@libertinus@serif{libertinusserif}%
      \gdef\zwu@font@family@libertinus@sans{libertinussans}%
      \gdef\zwu@font@name@libertinus@math{libertinusmath-regular}%
      \gdef\zwu@font@style@libertinus@rm{regular}%
      \gdef\zwu@font@style@libertinus@bf{bold}%
      \gdef\zwu@font@style@libertinus@it{italic}%
      \gdef\zwu@font@style@libertinus@bfit{bolditalic}%
    }%
  \fi
}

\newcommand\zwu@set@font@libertinus{%
  \zwu@set@libertinus@names
  \setmainfont{\zwu@font@family@libertinus@serif}[
    Extension      = .otf,
    UprightFont    = *-\zwu@font@style@libertinus@rm,
    BoldFont       = *-\zwu@font@style@libertinus@bf,
    ItalicFont     = *-\zwu@font@style@libertinus@it,
    BoldItalicFont = *-\zwu@font@style@libertinus@bfit,
  ]%
  \setsansfont{\zwu@font@family@libertinus@sans}[
    Extension      = .otf,
    UprightFont    = *-\zwu@font@style@libertinus@rm,
    BoldFont       = *-\zwu@font@style@libertinus@bf,
    ItalicFont     = *-\zwu@font@style@libertinus@it,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

% New Computer Modern
\newcommand\zwu@set@font@newcm{%
  \setmainfont{NewCM10}[
    Extension      = .otf,
    UprightFont    = *-Book,
    BoldFont       = *-Bold,
    ItalicFont     = *-BookItalic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \setsansfont{NewCMSans10}[
    Extension         = .otf,
    UprightFont       = *-Book,
    BoldFont          = *-Bold,
    ItalicFont        = *-BookOblique,
    BoldItalicFont    = *-BoldOblique,
  ]%
  \setmonofont{NewCMMono10}[
    Extension           = .otf,
    UprightFont         = *-Book,
    ItalicFont          = *-BookItalic,
    BoldFont            = *-Bold,
    BoldItalicFont      = *-BoldOblique,
  ]%
}

% Latin Modern
\newcommand\zwu@set@font@lm{%
  \setmainfont{lmroman10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setsansfont{lmsans10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

\newcommand\zwu@set@font@newtx{%
  \RequirePackage{newtxtext}%
}

\newcommand\zwu@set@font{%
  \@nameuse{zwu@set@font@\zwu@font}%
}
\zwu@set@font
\zwu@option@hook{font}{\zwu@set@font}

% 中文字体
\ifzwu@cjk@font@auto
  \ifzwu@fontset@mac
    \zwusetup{cjk-font = mac}
  \else
    \ifzwu@fontset@windows
      \zwusetup{cjk-font = windows}
    \else
      \ifzwu@fontset@ubuntu
        \zwusetup{cjk-font = noto}
      \else
        \zwusetup{cjk-font = fandol}
      \fi
    \fi
  \fi
\fi

% Windows 的中易字体。
\newcommand\zwu@set@cjk@font@windows{%
  \setCJKmainfont{SimSun}[
    AutoFakeBold = 3,
    ItalicFont   = KaiTi,
  ]%
  \setCJKsansfont{SimHei}[AutoFakeBold = 3]%
  \setCJKmonofont{FangSong}%
  \setCJKfamilyfont{zhsong}{SimSun}[AutoFakeBold = 3]%
  \setCJKfamilyfont{zhhei}{SimHei}[AutoFakeBold = 3]%
  \setCJKfamilyfont{zhkai}{KaiTi}%
  \setCJKfamilyfont{zhfs}{FangSong}%
}

% macOS 的华文字体。
\newcommand\zwu@set@cjk@font@mac{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{Songti SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = Kaiti SC Regular,
    BoldItalicFont = Kaiti SC Bold,
  ]%
  \setCJKsansfont{Heiti SC}[
    UprightFont    = * Light,
    BoldFont       = * Medium,
  ]%
  \setCJKmonofont{STFangsong}
  \setCJKfamilyfont{zhsong}{Songti SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
  ]%
  \setCJKfamilyfont{zhhei}{Heiti SC}[
    UprightFont    = * Light,
    BoldFont       = * Medium,
  ]%
  \setCJKfamilyfont{zhfs}{STFangsong}%
  \setCJKfamilyfont{zhkai}{Kaiti SC}[
    UprightFont    = * Regular,
    BoldFont       = * Bold,
  ]%
  \setCJKfamilyfont{zhli}{Baoli SC}%
  \setCJKfamilyfont{zhyuan}{Yuanyi SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
  ]%
}

% 思源字体。
% 注意 Noto CJK 的 regular 字重名字不带“Regular”。
\newcommand\zwu@set@cjk@font@noto{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{Noto Serif CJK SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = FandolKai-Regular,
    ItalicFeatures = {Extension = .otf},
    Script         = CJK,
  ]%
  \setCJKsansfont{Noto Sans CJK SC}[
    BoldFont       = * Medium,
    Script         = CJK,
  ]%
  \setCJKmonofont{Noto Sans Mono CJK SC}[
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhsong}{Noto Serif CJK SC}[
    UprightFont    = * Light,
    UprightFont    = * Bold,
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhhei}{Noto Sans CJK SC}[
    BoldFont       = * Medium,
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension      = .otf,
    UprightFont    = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension      = .otf,
    UprightFont    = *-Regular,
  ]%
}

% Fandol 字体。
\newcommand\zwu@set@cjk@font@fandol{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
    ItalicFont  = FandolKai-Regular,
    ItalicFeatures = {Extension = .otf},
  ]%
  \setCJKsansfont{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKmonofont{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhsong}{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhhei}{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
}

\ifzwu@cjk@font@none\else
  \providecommand\songti{\CJKfamily{zhsong}}
  \providecommand\heiti{\CJKfamily{zhhei}}
  \providecommand\fangsong{\CJKfamily{zhfs}}
  \providecommand\kaishu{\CJKfamily{zhkai}}
\fi

\newcommand\zwu@set@cjk@font{%
  \@nameuse{zwu@set@cjk@font@\zwu@cjk@font}%
}
\zwu@set@cjk@font
\zwu@option@hook{cjk-font}{\zwu@set@cjk@font}

% 数学字体

% 设置数学符号风格。
\newcommand\zwu@set@math@style{%
  \ifzwu@math@style@TeX
    \zwusetup{
      uppercase-greek    = upright,
      less-than-or-equal = horizontal,
      integral           = slanted,
      integral-limits    = false,
      partial            = italic,
      math-ellipsis      = AMS,
      real-part          = fraktur,
    }%
  \else
    \zwusetup{
      uppercase-greek = italic,
      integral        = upright,
      partial         = upright,
      real-part       = roman,
    }%
    \ifzwu@math@style@ISO
      \zwusetup{
        less-than-or-equal = horizontal,
        integral-limits    = true,
        math-ellipsis      = lower,
      }%
    \else
      \ifzwu@math@style@GB
        \zwusetup{
          less-than-or-equal = slanted,
          integral-limits    = false,
          math-ellipsis      = centered,
        }%
      \fi
    \fi
  \fi
}

\ifzwu@main@language@chinese
  \zwusetup{math-style = GB}%
\else
  \zwusetup{math-style = TeX}%
\fi

\zwu@set@math@style
\zwu@option@hook{math-style}{\zwu@set@math@style}
\zwu@option@hook{main-language}{%
  \ifzwu@main@language@chinese
    \zwusetup{math-style = GB}%
  \else
    \zwusetup{math-style = TeX}%
  \fi
}

% 针对 \pkg{unicode-math} 逐项配置数学符号。

\newcommand\zwu@set@unimath@leq{%
  \ifzwu@leq@horizontal
    \ifx\@begindocumenthook\@undefined
      \let\le\zwu@save@leq
      \let\ge\zwu@save@geq
      \let\leq\zwu@save@leq
      \let\geq\zwu@save@geq
    \else
      \AtBeginDocument{%
        \let\le\zwu@save@leq
        \let\ge\zwu@save@geq
        \let\leq\zwu@save@leq
        \let\geq\zwu@save@geq
      }%
    \fi
  \else
    \ifzwu@leq@slanted
      \ifx\@begindocumenthook\@undefined
        \let\le\leqslant
        \let\ge\geqslant
        \let\leq\leqslant
        \let\geq\geqslant
      \else
        \AtBeginDocument{%
          \let\le\leqslant
          \let\ge\geqslant
          \let\leq\leqslant
          \let\geq\geqslant
        }%
      \fi
    \fi
  \fi
}
\newcommand\zwu@set@unimath@integral@limits{%
  \ifzwu@integral@limits@true
    \removenolimits{%
      \int\iint\iiint\iiiint\oint\oiint\oiiint
      \intclockwise\varointclockwise\ointctrclockwise\sumint
      \intbar\intBar\fint\cirfnint\awint\rppolint
      \scpolint\npolint\pointint\sqint\intlarhk\intx
      \intcap\intcup\upint\lowint
    }%
  \else
    \addnolimits{%
      \int\iint\iiint\iiiint\oint\oiint\oiiint
      \intclockwise\varointclockwise\ointctrclockwise\sumint
      \intbar\intBar\fint\cirfnint\awint\rppolint
      \scpolint\npolint\pointint\sqint\intlarhk\intx
      \intcap\intcup\upint\lowint
    }%
  \fi
}
\newcommand\zwu@set@unimath@ellipsis{%
  \ifzwu@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\unicodecdots}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\unicodeellipsis}}%
  \fi
}
\newcommand\zwu@set@unimath@real@part{%
  \ifzwu@real@part@roman
    \AtBeginDocument{%
      \def\Re{\operatorname{Re}}%
      \def\Im{\operatorname{Im}}%
    }%
  \else
    \AtBeginDocument{%
      \let\Re\zwu@save@Re
      \let\Im\zwu@save@Im
    }%
  \fi
}

\newcommand\zwu@set@unimath@style{%
  \ifzwu@uppercase@greek@upright
    \unimathsetup{math-style = TeX}%
  \else
    \ifzwu@uppercase@greek@italic
      \unimathsetup{math-style = ISO}%
    \fi
  \fi
  \ifzwu@math@style@TeX
    \unimathsetup{bold-style = TeX}%
  \else
    \unimathsetup{bold-style = ISO}%
  \fi
  \zwu@set@unimath@leq
  \zwu@set@unimath@integral@limits
  \ifzwu@partial@upright
    \unimathsetup{partial = upright}%
  \else
    \ifzwu@partial@italic
      \unimathsetup{partial = italic}%
    \fi
  \fi
  \zwu@set@unimath@ellipsis
  \zwu@set@unimath@real@part
}

\newcommand\zwu@qed{\rule{1ex}{1ex}}
\newcommand\zwu@load@unimath{%
  \@ifpackageloaded{unicode-math}{}{%
    \RequirePackage{unicode-math}%
    \AtBeginDocument{%
      \let\zwu@save@leq\leq
      \let\zwu@save@geq\geq
      \let\zwu@save@Re\Re
      \let\zwu@save@Im\Im
    }%
    %
    % 兼容旧的粗体命令：\pkg{bm} 的 \cs{bm} 和 \pkg{amsmath} 的 \cs{boldsymbol}。
    \DeclareRobustCommand\bm[1]{{\symbfit{##1}}}%
    \DeclareRobustCommand\boldsymbol[1]{{\symbfit{##1}}}%
    %
    % 兼容 \pkg{amsfonts} 和 \pkg{amssymb} 中的一些命令。
    \newcommand\square{\mdlgwhtsquare}%
    \newcommand\blacksquare{\mdlgblksquare}%
    \AtBeginDocument{%
      \renewcommand\checkmark{\ensuremath{✓}}%
    }%
    %
    % 兼容 \pkg{amsthm} 的 \cs{qedsymbol}。
    \renewcommand\zwu@qed{\ensuremath{\QED}}%
  }%
}

% STIX Two Math
\newcommand\zwu@set@math@font@stix{%
  \zwu@load@unimath
  \zwu@set@unimath@style
  \zwu@set@stix@names
  \setmathfont{\zwu@font@name@stix@math}[
    Extension    = .otf,
    Scale        = MatchLowercase,
    StylisticSet = \zwu@xits@integral@stylistic@set,
  ]%
  \setmathfont{\zwu@font@name@stix@math}[
    Extension    = .otf,
    Scale        = MatchLowercase,
    StylisticSet = 1,
    range        = {scr,bfscr},
  ]%
}

% XITS Math
\newcommand\zwu@xits@integral@stylistic@set{%
  \ifzwu@integral@upright
    8%
  \fi
}
\newcommand\zwu@set@math@font@xits{%
  \zwu@load@unimath
  \zwu@set@unimath@style
  \zwu@set@xits@names
  \setmathfont{\zwu@font@name@xits@math}[
    Extension    = .otf,
    StylisticSet = \zwu@xits@integral@stylistic@set,
  ]%
  \setmathfont{\zwu@font@name@xits@math}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {cal,bfcal},
  ]%
}

% Libertinus Math
\newcommand\zwu@libertinus@integral@stylistic@set{%
  \ifzwu@integral@slanted
    8%
  \fi
}
\newcommand\zwu@set@math@font@libertinus{%
  \zwu@load@unimath
  \zwu@set@unimath@style
  \zwu@set@libertinus@names
  \zwu@set@xits@names
  \setmathfont{\zwu@font@name@libertinus@math}[
    Extension    = .otf,
    StylisticSet = \zwu@libertinus@integral@stylistic@set,
  ]%
  \setmathfont{\zwu@font@name@xits@math}[
    Extension    = .otf,
    range        = {\checkmark},
  ]%
}

% New Computer Modern Math
\newcommand\zwu@newcm@integral@stylistic@set{%
  \ifzwu@integral@upright
    2%
  \fi
}
\newcommand\zwu@set@math@font@newcm{%
  \zwu@load@unimath
  \zwu@set@unimath@style
  \setmathfont{NewCMMath-Book}[
    Extension    = .otf,
    StylisticSet = \zwu@newcm@integral@stylistic@set,
  ]%
  \setmathfont{NewCMMath-Book}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {scr,bfscr},
  ]%
  \setmathrm{NewCM10}[
    Extension      = .otf,
    UprightFont    = *-Book,
    BoldFont       = *-Bold,
    ItalicFont     = *-BookItalic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \setmathsf{NewCMSans10}[
    Extension         = .otf,
    UprightFont       = *-Book,
    BoldFont          = *-Bold,
    ItalicFont        = *-BookOblique,
    BoldItalicFont    = *-BoldOblique,
  ]%
  \setmathtt{NewCMMono10}[
    Extension           = .otf,
    UprightFont         = *-Book,
    ItalicFont          = *-BookItalic,
    BoldFont            = *-Bold,
    BoldItalicFont      = *-BoldOblique,
  ]%
}

% Latin Modern Math
\newcommand\zwu@set@math@font@lm{%
  \zwu@load@unimath
  \zwu@set@unimath@style
  \setmathfont{latinmodern-math}[Extension=.otf]%
  \setmathrm{lmroman10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setmathsf{lmsans10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
  \setmathtt{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

% NewTX Math
% 注意 NewTX Math 是 Type 1 字体，如果正文西文使用了 OpenType 字体时需要小心处理。
\newcommand\zwu@set@math@font@newtx{%
  \ifzwu@font@newtx\else
    \let\zwu@save@encodingdefault\encodingdefault
    \let\zwu@save@rmdefault\rmdefault
    \let\zwu@save@sfdefault\sfdefault
    \let\zwu@save@ttdefault\ttdefault
    \RequirePackage[T1]{fontenc}%
    \renewcommand{\rmdefault}{ntxtlf}%
    \renewcommand{\sfdefault}{qhv}%
    \renewcommand{\ttdefault}{ntxtt}%
  \fi
  \ifzwu@uppercase@greek@italic
    \PassOptionsToPackage{slantedGreek}{newtxmath}%
  \fi
  \ifzwu@integral@upright
    \PassOptionsToPackage{upint}{newtxmath}%
  \fi
  \RequirePackage{newtxmath}
  \let\zwu@save@leq\leq
  \let\zwu@save@geq\geq
  \ifzwu@leq@slanted
    \let\le\leqslant
    \let\ge\geqslant
    \let\leq\leqslant
    \let\geq\geqslant
  \fi
  \ifzwu@integral@limits@true
    \let\ilimits@\displaylimits
  \fi
  \let\zwu@save@partial\partial
  \ifzwu@partial@upright
    \let\partial\uppartial
  \fi
  \ifzwu@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\cdotp\cdotp\cdotp}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\ldotp\ldotp\ldotp}}%
  \fi
  \let\zwu@save@Re\Re
  \let\zwu@save@Im\Im
  \ifzwu@real@part@roman
    \def\Re{\operatorname{Re}}%
    \def\Im{\operatorname{Im}}%
  \fi
  \RequirePackage{bm}%
  \ifzwu@font@newtx\else
    \let\encodingdefault\zwu@save@encodingdefault
    \let\rmdefault\zwu@save@rmdefault
    \let\sfdefault\zwu@save@sfdefault
    \let\ttdefault\zwu@save@ttdefault
  \fi
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\upDelta%
  \renewcommand\zwu@qed{\openbox}%
}

% Computer Modern
% 使用 LaTeX 默认的 cm 字体
\newcommand\zwu@set@math@font@cm{%
  \RequirePackage{amssymb}
  \let\zwu@save@leq\leq
  \let\zwu@save@geq\geq
  \ifzwu@leq@slanted
    \let\le\leqslant
    \let\ge\geqslant
    \let\leq\leqslant
    \let\geq\geqslant
  \fi
  \ifzwu@integral@limits@true
    \let\ilimits@\displaylimits
  \fi
  \ifzwu@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\cdotp\cdotp\cdotp}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\ldotp\ldotp\ldotp}}%
  \fi
  \let\zwu@save@Re\Re
  \let\zwu@save@Im\Im
  \ifzwu@real@part@roman
    \def\Re{\operatorname{Re}}%
    \def\Im{\operatorname{Im}}%
  \fi
  \RequirePackage{bm}%
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\Delta
  \renewcommand\zwu@qed{\openbox}%
  \let\uppi\pi
}

% 不设置数学字体，仅提供兼容支持。
\newcommand\zwu@set@math@font@none{%
  \RequirePackage{amssymb}
  \RequirePackage{bm}%
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\Delta
  \renewcommand\zwu@qed{\openbox}%
  \let\uppi\pi
}

\newcommand\zwu@set@math@font{%
  \@nameuse{zwu@set@math@font@\zwu@math@font}%
}
\zwu@option@hook{math-font}{\g@addto@macro\zwu@setup@hook{\zwu@set@math@font}}
\newcommand\zwu@set@math@font@auto{%
  \ifzwu@math@font@auto
    \zwusetup{math-font=xits}%
  \fi
}
\AtBeginOfPackageFile*{siunitx}{\zwu@set@math@font@auto}
\AtEndPreamble{%
  \zwu@set@math@font@auto
  \ifx\square\@undefined
    \RequirePackage{amssymb}%
  \fi
}



% \subsection{纸张和页面}
% 使用 \pkg{geometry} 宏包设置纸张和页面。

% 纸张：A4；

% 页面设置：上、下 2.54 cm，左、右 3.17 cm，页眉 1.5 cm，页脚 1.75 cm。

% 注意这里指的是页眉顶部到纸张顶部的距离为 1.5 cm，
% 所以应该是 2.54cm - 0.8cm - 0.24cm = 1.5cm

\geometry{
  paper      = a4paper,
  vmargin    = 2.54cm,
  hmargin    = 3.17cm,
  headheight = 0.75cm,
  headsep    = 0.29cm,
  footskip   = 0.79cm,
}

% 使用 \pkg{fancy} 需要先调用 |\pagestyle{fancy}| 再修改 \cs{chaptermark} 和
% \cs{sectionmark}。
\pagestyle{fancy}
\let\sectionmark\@gobble
\renewcommand\headrulewidth{0.4\p@}

% 重定义默认的 |plain| page style，会显示页眉和页脚。
\fancypagestyle{plain}{%
  \fancyhf{}%
  %
  % 页眉与该部分的章标题相同，宋体 10.5 磅（五号）居中。
  % 页码：宋体 10.5 磅、页面下脚居中。
    %
    % 本科生要求除封面、扉页外，每面上部加页眉，
    % 用小 5 号字（9 bp）标注“中国科学技术大学本科毕业论文”，居中；
    % 从目录页开始在每面底部居中用小五宋体（9 bp）连续编页码。
    \def\zwu@hf@font{\fontsize{9bp}{12bp}\selectfont}
    \fancyhead[C]{\zwu@hf@font 中国科学技术大学本科毕业论文}%
    \fancyfoot[C]{\zwu@hf@font\thepage}%
    \let\@mkboth\@gobbletwo
    \let\chaptermark\@gobble
    \let\sectionmark\@gobble
}
\pagestyle{plain}

% |headings| 只有页眉，没有页脚，用于研究生的符号说明和本科生的 front matter。
\fancypagestyle{headings}{\fancyfoot{}}

% 设置特殊的 page style 不改变任何内容，用于每章首页。
\def\ps@chapter{}
\ctexset{chapter/pagestyle=chapter}

% 空白页不加页眉和页码。
\def\cleardoublepage{%
  \clearpage
  \if@twoside
    \ifodd\c@page\else
      \hbox{}%
      \thispagestyle{empty}%
      \newpage
      \if@twocolumn
        \hbox{}%
        \newpage
      \fi
    \fi
  \fi
}

%
% 研究生要求从“中文摘要”开始页码用大写罗马数字，
% 而本科生的 frontmatter（只有致谢）不编页码，从目录开始页码用阿拉伯数字。
\renewcommand\frontmatter{%
  \cleardoublepage
  \@mainmatterfalse
  \pagenumbering{Roman}%
  \pagestyle{headings}%
}

% 研究生要求“第 1 章”要另页起，但是本科生要求另面起。
\renewcommand\mainmatter{%
  \clearpage
  \pagestyle{plain}%
  \@mainmattertrue
}

\g@addto@macro\appendix{\@mainmattertrue}%


% \subsection{封面}


% 定义用户接口：
\zwu@define@key{
  title = {
    default = {论文题目},
  },
  title* = {
    default = {Title},
    name    = title@en,
  },
  author = {
    default = {作者姓名},
  },
  author* = {
    default = {Author Name},
    name    = author@en,
  },
  speciality = {
    default = {专业},
  },
  speciality* = {
    default = {Speciality},
    name    = speciality@en,
  },
  supervisor = {
    default = {导师姓名},
  },
  supervisor* = {
    default = {Supervisor Name},
    name    = supervisor@en,
  },
  advisor = {
    default = {},
  },
  advisor* = {
    default = {},
    name    = advisor@en,
  },
  date = {
    default = {\the\year-\two@digits{\month}-\two@digits{\day}},
  },
  professional-type = {
    name = professional@type,
  },
  professional-type* = {
    name = professional@type@en,
  },
  department,
  student-id = {
    name = student@id,
  },
  secret-level = {
    name    = secret@level,
  },
  secret-level* = {
    name    = secret@level@en,
  },
  secret-year = {
    name    = secret@year,
  },
  keywords,
  keywords* = {
    name    = keywords@en,
  },
}

% 导师一栏可能有多个姓名，所以用 \opt{supervisor} 进行收集，
% 然后使用本命令来输出要求的格式，
% 类似于 \LaTeX3 的 \cs{clist\_use:Nn}。
\newcommand\zwu@clist@count[1]{%
  \csname clist_count:N\endcsname{#1}%
}
\newcommand\zwu@clist@use[2]{%
  \csname clist_use:Nn\endcsname{#1}{#2}%
}
\newcommand\zwu@supervisor@names{%
  \zwu@clist@use{\zwu@supervisor}{\quad}
}
\newcommand\zwu@advisor@names{%
  \zwu@clist@use{\zwu@advisor}{\quad}
}
\newcounter{zwu@count}
\newcommand\zwu@supervisor@en@line{%
  \setcounter{zwu@count}{\zwu@clist@count{\zwu@supervisor@en}}%
  \ifnum\c@zwu@count>1\relax
    Supervisors:%
  \else
    Supervisor:%
  \fi
  \space\zwu@clist@use{\zwu@supervisor@en}{, }%
}
\newcommand\zwu@advisor@en@line{%
  \setcounter{zwu@count}{\zwu@clist@count{\zwu@advisor@en}}%
  \ifnum\c@zwu@count>1\relax
    Advisor:%
  \else
    Advisor:%
  \fi
  \space\zwu@clist@use{\zwu@advisor@en}{, }%
}

% 输出日期的给定格式：\cs{zwu@format@date}\marg{format}\marg{date}，
% 其中格式 \meta{format} 接受三个参数分别对应年、月、日，
% \meta{date} 是 ISO 格式的日期（yyyy-mm-dd）。
\newcommand\zwu@format@date[2]{%
  \edef\zwu@@date{#2}%
  \def\zwu@@process@date##1-##2-##3\@nil{%
    #1{##1}{##2}{##3}%
  }%
  \expandafter\zwu@@process@date\zwu@@date\@nil
}
\newcommand\zwu@date@format@zh@small[3]{\number#1 年 \number#2 月 \number#3 日}
\newcommand\zwu@date@format@zh@big[3]{\zhdigits{#1}年\zhnumber{#2}月\zhnumber{#3}日}
\newcommand\zwu@date@month[1]{%
  \ifcase\number#1\or
    January\or February\or March\or April\or May\or June\or
    July\or August\or September\or October\or November\or December%
  \fi
}
\newcommand\zwu@date@format@zh@short[3]{\number#1 年 \number#2 月}
\newcommand\zwu@date@format@en[3]{\zwu@date@month{#2} \number#3, #1}
\newcommand\zwu@date@zh@small{\zwu@format@date{\zwu@date@format@zh@small}{\zwu@date}}
\newcommand\zwu@date@zh@big{\zwu@format@date{\zwu@date@format@zh@big}{\zwu@date}}
\newcommand\zwu@date@zh@short{\zwu@format@date{\zwu@date@format@zh@short}{\zwu@date}}
\newcommand\zwu@date@en{\zwu@format@date{\zwu@date@format@en}{\zwu@date}}

% 版本 v3.2 开始使用 \cs{zwusetup} 设置接口，
% 兼容旧版本的命令式设置。
% Reserved for compatibility until 2020-07-01.
\def\zwu@define@term#1#2{%
  \expandafter\gdef\csname #1\endcsname##1{%
    \zwusetup{#2 = {##1}}%
  }%
}
\zwu@define@term{title}{title}
\zwu@define@term{entitle}{title*}
\zwu@define@term{author}{author}
\zwu@define@term{enauthor}{author*}
\zwu@define@term{major}{speciality}
\zwu@define@term{enmajor}{speciality*}
\zwu@define@term{supervisor}{supervisor}
\zwu@define@term{ensupervisor}{supervisor*}
\gdef\cosupervisor#1{%
  \g@addto@macro\zwu@supervisor{, #1}%
}
\gdef\encosupervisor#1{%
  \g@addto@macro\zwu@supervisor@en{, #1}%
}
\gdef\date#1{\renewcommand\zwu@date@zh@big{#1}}
\gdef\endate#1{\renewcommand\zwu@date@en{#1}}
\zwu@define@term{professionaltype}{professional-type}
\zwu@define@term{enprofessionaltype}{professional-type*}
\zwu@define@term{secretlevel}{secret-level}
\zwu@define@term{ensecretlevel}{secret-level*}
\zwu@define@term{secretyear}{secret-year}
\gdef\keywords#1{\renewcommand\zwu@keywords@text{#1}}
\gdef\enkeywords#1{\renewcommand\zwu@keywords@en@text{#1}}

% 定义一些常量。

\newcommand\zwu@thesis@name{学士学位论文}
\newcommand\zwu@thesis@name@en{A dissertation for bachelor's degree}

  \ifzwu@cjk@font@mac
    \providecommand\lishu{\CJKfamily{zhli}}
  \else
    \ifzwu@cjk@font@windows
      \setCJKfamilyfont{zhli}{LiSu}
      \providecommand\lishu{\CJKfamily{zhli}}
    \else
      \zwu@warning{LiShu font is required}
      \providecommand\lishu{\sffamily}
    \fi
  \fi
  \newcommand\zwu@speciality@name{专业领域}

  % 定义校徽颜色
%
% 推迟定义颜色以避免调用 \pkg{xcolor} 时的警告
\AtBeginDocument{
  \definecolor{zwublue}{cmyk}{1,0.8,0,0}
}

% 添加 PDF 书签，在 \pkg{hyperref} 载入后才有效。
\newcommand\zwu@pdfbookmark{\@gobble}

% 重定义 \env{titlepage} 环境，不修改页码。
\renewenvironment{titlepage}{%
  \cleardoublepage
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse\newpage
  \fi
  \thispagestyle{empty}%
}{%
  \if@restonecol\twocolumn \else \newpage \fi
}

% 中文封面：
% 密级仿宋 14 磅；
% 论文类型黑体 56 磅；
% 论文题目黑体 26 磅加粗居中，单倍行距；
% 作者姓名宋体 16 磅，单倍行距；
% 注意这里的“单倍行距”的地方开启了“对齐到网格”，所以实际行距有所偏差，
% 所以只能使用直尺测量。
\newcommand\zwu@speciality@sse{软件工程}
\newcommand\zwu@title@page@graduate@zh{%
\zwusetup{language=chinese}%
\begin{titlepage}%
  \zwu@pdfbookmark{封面}%
    \centering
    \parbox[t][0.6cm][t]{\textwidth}{%
      \raggedleft\fangsong\fontsize{14bp}{14bp}\selectfont
      \null\zwu@secret@level\par}\par
    \vskip 0.5cm%
    \includegraphics[height=1.3cm]{figures/zwu-name.pdf}\par
    \vskip 0.6cm%
    {\sffamily\fontsize{56bp}{56bp}\selectfont
      \zwu@thesis@name\par}%
    
    \includegraphics[height=4.1cm]{figures/zwu-badge.pdf}%
    \par
    \vskip 0.9cm%
    \parbox[t][3.5cm][c]{\textwidth}{%
      \centering\sffamily\bfseries\fontsize{26bp}{50bp}\selectfont
      \zwu@title\par}\par
    \vskip 0.6cm%
    {\fontsize{16bp}{31bp}\selectfont
      \begin{tabular}{@{}l@{\hspace{\ccwd}}l@{}}%
        \textsf{作者姓名：} & \zwu@author \\
        \textsf{\zwu@speciality@name：} & \zwu@speciality \\
        \ifx\zwu@advisor\@empty
          \textsf{导师姓名：} & \zwu@supervisor@names \\
        \else
          \textsf{校内导师：} & \zwu@supervisor@names \\
          \textsf{企业导师：} & \zwu@advisor@names \\
        \fi
        \textsf{完成时间：} & \zwu@date@zh@big
      \end{tabular}\par}%
  \end{titlepage}%
  \zwu@reset@main@language
}

% 英文封面
\newcommand\zwu@title@page@graduate@en{%
  \zwusetup{language=english}%
  \begin{titlepage}%
    \zwu@pdfbookmark{Title page}%
    \centering
    \parbox[t][0.4cm][t]{\textwidth}{%
      \raggedleft\fontsize{14bp}{14bp}\selectfont
      \null\zwu@secret@level@en\par}\par
    \vskip 0.5cm%
    {\sffamily\fontsize{20bp}{30bp}\selectfont
      University of Science and Technology of China\par}%
    {\sffamily\fontsize{26bp}{30bp}\selectfont
      \zwu@thesis@name@en\par}%
    \vskip 2.5cm%
    \includegraphics[height=4.5cm]{figures/zwu-badge.pdf}%
    \par
    \vskip 0.5cm%
    \parbox[t][4.5cm][c]{\textwidth}{%
      \centering\sffamily\bfseries\fontsize{26bp}{30bp}\selectfont
      \zwu@title@en\par}\par
    \vskip 1.6cm%
    {\fontsize{16bp}{30bp}\selectfont
      \begin{tabular}{@{}l@{}}%
        Author:        \zwu@author@en \\
        Speciality:    \zwu@speciality@en \\
        \zwu@supervisor@en@line \\
        \ifx\zwu@advisor\@empty
        \else
          \zwu@advisor@en@line \\
        \fi
        Finished time: \zwu@date@en
      \end{tabular}\par}%
  \end{titlepage}%
  \zwu@reset@main@language
}

\newbox\zwu@title@box

% 本科生的外封
\newcommand\zwu@cover{%
  \begin{titlepage}%
    \zwu@pdfbookmark{Cover}%
    \centering
    \vspace*{0.8cm}%
    \includegraphics{figures/zwu-title-page-heading.pdf}%
    \vskip 4.3cm%
    \begingroup
      \bfseries\fontsize{15bp}{16bp}\selectfont
      \setlength\tabcolsep{\z@}%
      \setlength\arrayrulewidth{1.5pt}%
      \begin{tabular}{lp{140bp}lp{140bp}}%
        题\quad 目 &
          \multicolumn{3}{c}{%
            \multirow[t]{2}{325bp}{%
              \savebox\zwu@title@box{%
                \parbox[t]{325bp}{%
                  \centering\fontsize{15bp}{40bp}\selectfont
                  \zwu@title
                }%
              }%
              \dp\zwu@title@box=0pt\relax
              \usebox\zwu@title@box
            }%
          } \\
        \cline{2-4}%
        \noalign{\vskip 24bp}%
        & & & \\
        \cline{2-4}%
        \noalign{\vskip 24bp}%
        英\quad 文 &
          \multicolumn{3}{c}{%
            \multirow[t]{3}{325bp}{%
              \savebox\zwu@title@box{%
                \parbox[t]{325bp}{%
                  \centering\fontsize{15bp}{40bp}\selectfont
                  \zwu@title@en
                }%
              }%
              \dp\zwu@title@box=0pt\relax
              \usebox\zwu@title@box
            }%
          } \\
        \cline{2-4}%
        \noalign{\vskip 24bp}%
        题\quad 目 & & & \\
        \cline{2-4}%
        \noalign{\vskip 24bp}%
        & & & \\
        \cline{2-4}%
        \noalign{\vskip 24bp}%
        院\quad 系 & \multicolumn{3}{c}{\zwu@department} \\
        \cline{2-4}%
        \noalign{\vskip 24bp}%
        姓\quad 名 & \multicolumn{1}{c}{\zwu@author} &
        学\quad 号 & \multicolumn{1}{c}{\zwu@student@id} \\
        \cline{2-2}%
        \cline{4-4}%
        \noalign{\vskip 24bp}%
        导\quad 师 & \multicolumn{3}{c}{\zwu@supervisor@names} \\
        \cline{2-4}%
        \noalign{\vskip 24bp}%
        日\quad 期 & \multicolumn{3}{c}{\zwu@date@zh@small} \\
        \cline{2-4}%
      \end{tabular}%
    \endgroup
  \end{titlepage}%
}

% 本科生的扉页（内封）
\newcommand\zwu@title@page@bachelor{%
  \begin{titlepage}%
    \zwu@pdfbookmark{Title page}%
    \centering
    % \vspace*{68bp}%
    \vspace*{29.5bp}%
    \includegraphics{figures/zwu-name-stxingkai.pdf}\par
    \vspace{0.8bp}%
    \begingroup
      \sffamily\fontsize{56bp}{72.8bp}\selectfont
      \renewcommand\CJKglue{\hspace{6.2bp}}%
      本科毕业论文\par
    \endgroup
    \vspace{52bp}%
    \ifzwu@badge@color@blue
      \textcolor{zwublue}{%
        \includegraphics[height=126bp]{figures/zwu-badge.pdf}}%
    \else
      \includegraphics[height=4.1cm]{figures/zwu-badge.pdf}%
    \fi\par
    \vspace{43bp}%
    \parbox[t][115bp][t]{\textwidth}{%
      \centering\sffamily\bfseries\fontsize{26bp}{46.8bp}\selectfont
      \zwu@title\par
    }\par
    \begingroup
      \hspace{10bp}%
      \heiti\fontsize{16bp}{31.7bp}\selectfont
      \setlength\tabcolsep{0bp}%
      \setlength\arrayrulewidth{0.5pt}%
      \setlength\zwu@title@page@item@width{238bp}%
      \begin{tabular}{p{90bp}c}%
        作者姓名： & \makebox[238bp]{\zwu@author} \\
        \cline{2-2}%
        学\quad\quad 号： & \makebox[238bp]{\zwu@student@id} \\
        \cline{2-2}%
        专\quad\quad 业： & \makebox[238bp]{\zwu@speciality} \\
        \cline{2-2}%
        导师姓名： & \makebox[238bp]{\zwu@supervisor@names} \\
        \cline{2-2}%
        完成时间： & \makebox[238bp]{\zwu@date@zh@small} \\
        \cline{2-2}%
      \end{tabular}\par
    \endgroup
  \end{titlepage}%
}
\newlength\zwu@title@page@item@width

% 重新定义 \cs{maketitle}，调用 \cs{zwu@makezhtitle}, \cs{zwu@makeentitle}
% 分别生成中、英文封面。
\renewcommand\maketitle{%
  \newgeometry{margin=2.54cm}%
  \pagenumbering{Alph}%
  \pagestyle{empty}%
  \zwu@title@page@bachelor
  \cleardoublepage
  \restoregeometry
  \pagestyle{plain}%
  
}


% \subsection{原创性声明}

% 定义原创性声明
\newcommand\zwu@originality{%
  本人声明所呈交的学位论文，是本人在导师指导下进行研究工作所取得的成果。%
  除已特别加以标注和致谢的地方外，论文中不包含任何他人已经发表或撰写过的%
  研究成果。%
  与我一同工作的同志对本研究所做的贡献均已在论文中作了明确的说明。}
\newcommand\zwu@authorization{%
  作为申请学位的条件之一，学位论文著作权拥有者授权中国科学技术大学拥有%
  学位论文的部分使用权，%
  即：学校有权按有关规定向国家有关部门或机构送交论文的复印件和电子版，%
  允许论文被查阅和借阅，可以将学位论文编入《中国学位论文全文数据库》等%
  有关数据库进行检索，可以采用影印、缩印或扫描等复制手段保存、汇编学位论文。%
  本人提交的电子文档的内容和纸质论文的内容相一致。\par
  控阅的学位论文在解密后也遵守此规定。}
  %
  % 生成空的下划线
\newcommand\zwu@underline[2][3.2cm]{\underline{\hb@xt@ #1{\hss#2\hss}}}

\newcommand\zwu@checkbox{%
  \makebox[\z@][l]{$\square$}%
  \raisebox{-0.2ex}{\hspace{0.1em}$\checkmark$}%
}

\newcommand\copyrightpage{%
  \begin{titlepage}%
    \zwu@pdfbookmark{原创性和授权使用声明}%
    \null
    \vskip 0.3cm%
    {\centering\sffamily\fontsize{16bp}{32bp}\selectfont
      中国科学技术大学学位论文原创性声明\par}%
    \vskip 0.7cm%
    \zwu@originality\par
    \vskip 1.3cm%
    作者签名：\zwu@underline{}\hspace{2.7cm}%
    签字日期：\zwu@underline{}\par
    \vskip 1.9cm%
    {\centering\sffamily\fontsize{16bp}{32bp}\selectfont
      中国科学技术大学学位论文授权使用声明\par}%
    \vskip 0.7cm%
    \zwu@authorization\par
    \vskip 0.6cm%
    \ifx\zwu@secret@level\@empty
      \zwu@checkbox{} 公开\quad
      $\square$ 控阅（\zwu@underline[0.85cm]{}年）\par
    \else
      $\square$ 公开\quad
      \zwu@checkbox{} 控阅（\zwu@underline[0.8cm]{\zwu@secret@year}年）\par
    \fi
    \vskip 0.5cm%
    作者签名：\zwu@underline{}\hspace{2.7cm}%
    导师签名：\zwu@underline{}\par
    \vskip 0.5cm%
    签字日期：\zwu@underline{}\hspace{2.7cm}%
    签字日期：\zwu@underline{}\par
    \ifzwu@reviewer@true
      \vskip 1.5cm%
      \hskip -1em%
      评审专家签名：\zwu@underline{}\hspace{4.5em}%
      评审专家签名：\zwu@underline{}\par
    \fi
  \end{titlepage}%
}
\ifzwu@degree@bachelor
  \let\copyrightpage\relax
\fi
% Reserved for compatibility until 2020-07-01.
\let\makestatement\copyrightpage


% \subsection{章节标题}

% 标题最多允许使用五级。
\setcounter{secnumdepth}{5}

% 研究生规定章题为两字时中间空两字，三字时空一字，四字时空半字，四字以上不空。
% 这里用 \LaTeX3 的 \cs{str\_count:N} 判断字数。
% 注意，\pkg{stringstrings} 宏包会导致范数命令 \verb+\|+ 被修改。
\newcount\zwu@titlelength
\DeclareRobustCommand\zwu@spacetitle[1]{%
  \zwu@titlelength=\csname str_count:N\endcsname{#1}%
  \begingroup
      \if@mainmatter\else
        \ifcase\zwu@titlelength
        \or\or
          \ziju{1}%
        \or\or
          \ziju{0.5}%
        \fi
      \fi
    #1%
  \endgroup
}

% 五级节标题和脚注需要使用带圈的数字，这里使用 \cs{zwu@circlefont} ：
\newcommand\zwu@textcircled[1]{%
  \ifnum\value{#1}<21\relax
    {\symbol{\numexpr\value{#1} + "245F\relax}}%
  \else
    \zwu@error{Cannot display more than 20 footnotes}%
  \fi
}

% 用 \pkg{ctex} 的接口设置全部章节标题格式。

% 各章标题：黑体 16 磅加粗居中，单倍行距，段前 24 磅，段后 18 磅，
% 章序号与章名间空一字。

% 由于 Word 模板中使用“单倍行距”，还“对齐到网格”，这在 TeX 中不容易实现。
% 所以目前按照默认的行距。

% 注意 \pkg{ctex} v2.4.3 以下版本的bug会导致章节标题前后的距离的实际值偏大。
% 另外 \pkg{ctex} v2.2 前的beforeskip的符号有特殊意义。
\ctexset{
  chapter = {
    format      = \centering\sffamily\bfseries\fontsize{16bp}{26.67bp}\selectfont,
    nameformat  = {},
    titleformat = \zwu@spacetitle,
    number      = \thechapter,
    aftername   = \hspace{\ccwd},
    beforeskip  = 24bp,
    afterskip   = 18bp,
    fixskip     = true,
  },
}

% 一级节标题：黑体 14 磅左顶格，单倍行距，段前 24 磅，段后 6 磅，
% 序号与题名间空一字。
\ctexset{
  section = {
    format     = \sffamily\fontsize{14bp}{23.33bp}\selectfont,
    aftername  = \hspace{\ccwd},
    beforeskip = 24bp,
    afterskip  = 6bp,
  },
  %
  % 二级节标题：黑体 13 磅，左缩进两字，单倍行距，段前 12 磅，段后 6 磅，
  % 序号与题名间空一字。
  subsection = {
    format     = \sffamily\fontsize{13bp}{21.67bp}\selectfont,
    aftername  = \hspace{\ccwd},
    indent     = 2\ccwd,
    beforeskip = 12bp,
    afterskip  = 6bp,
  },
  %
  % 三级及以下节标题的格式没有具体规定，按照 Word 模板的格式：
  % 使用黑体 12 磅，左缩进两字，行距 20 磅，段前段后 0 磅，序号与题名间空半字宽。
  subsubsection = {
    format     = \sffamily\fontsize{12bp}{20bp}\selectfont,
    number     = \arabic{subsubsection},
    aftername  = .\hspace{0.5\ccwd},
    indent     = 2\ccwd,
    beforeskip = \z@,
    afterskip  = \z@,
  },
  %
  % 按照 Word 模板的格式，四级节标题：宋体 12 磅，左缩进两字，行距 20 磅，
  % 段前段后 0 磅，序号使用全宽括号，与题名间空半字宽。
  paragraph = {
    format     = \rmfamily\fontsize{12bp}{20bp}\selectfont,
    number     = （\arabic{paragraph}）,
    aftername  = \hspace{0.5\ccwd},
    indent     = 2\ccwd,
    beforeskip = \z@,
    afterskip  = \z@,
    runin      = false,
  },
  %
  % 按照 Word 模板的格式，五级节标题：宋体 12 磅，左缩进两字，行距 20 磅，
  % 段前段后 0 磅，序号使用全宽括号，与题名间空半字宽。
  subparagraph = {
    format     = \rmfamily\fontsize{12bp}{20bp}\selectfont,
    number     = \zwu@textcircled{subparagraph},
    aftername  = \hspace{0.5\ccwd},
    indent     = 2\ccwd,
    beforeskip = \z@,
    afterskip  = \z@,
    runin      = false,
  },
}

\ifzwu@degree@bachelor
  \ifzwu@main@language@english
    \zwusetup{section-style = arabic}
  \fi
\fi
\zwu@option@hook{main-language}{%
  \ifzwu@degree@bachelor
    \ifzwu@main@language@english
      \zwusetup{section-style = arabic}%
    \fi
  \fi
}

% 在研究生格式的基础上再设置本科生的章节标题格式。
  \setcounter{secnumdepth}{4}
  \ctexset{
  %
  % 论文的致谢、目录、摘要和参考文献等标题用小二号（18 bp）黑体字，居中，
  % 这通过 \cs{if@mainmatter} 区分。
  % 正文中的标题分章、节、段三级；章、节标题居中，段标题居左，
  % 分别用三号（16 bp）黑体、小三（15 bp）黑体、四号（14 bp）黑体。
    chapter = {
      format = {
        \centering\sffamily
        \if@mainmatter
          \fontsize{16bp}{29.33bp}\selectfont
        \else
          \fontsize{18bp}{33bp}\selectfont
        \fi
      },
    },
    section = {
      format = \centering\sffamily\fontsize{15bp}{27.5bp}\selectfont,
    },
    subsection = {
      format    = \sffamily\fontsize{14bp}{25.67bp}\selectfont,
      indent    = \z@,
    },
    subsubsection = {
      format    = \rmfamily\fontsize{12bp}{22bp}\selectfont,
      indent    = \ccwd,
    },
    paragraph = {
      format    = \rmfamily\fontsize{12bp}{22bp}\selectfont,
      aftername = {},
      indent    = \ccwd,
    },
  }
  %
  % 本科生的阿拉伯数字式标题的格式与研究生几乎一致，只有中文数字式需要修改。
  \ifzwu@section@style@arabic\else
    \ctexset{
      chapter = {
        number = \chinese{chapter},
      },
      section = {
        name   = {第,节},
        number = \chinese{section},
      },
      subsection = {
        number    = \chinese{subsection},
        aftername = {、},
      },
    }
  \fi

% 默认的 \cs{chapter*} 生成的章标题没有编号、不更改页眉，
% 也不添加进目录或 PDF 书签。
% 然而像摘要、目录、符号说明这样的章节，它们不需要编号、不加入目录，
% 但是需要修改页眉，并且加入 PDF 标签。
% 所以我们新定义 \cs{zwu@chapter} 用于处理这些章节。%
\NewDocumentCommand\zwu@chapter{o m}{%
  \if@openright\cleardoublepage\else\clearpage\fi
  \IfValueTF{#1}{%
    \zwu@pdfbookmark{#1}%
    \chaptermark{#1}%
  }{%
    \zwu@pdfbookmark{#2}%
    \chaptermark{#2}%
  }%
  \chapter*{#2}}


% \subsection{摘要}

% 中文摘要环境。
\newcommand\zwu@keywords@text{%
  \zwu@clist@use{\zwu@keywords}{、}%
}
\newcommand\zwu@keywords@en@text{%
  \zwu@clist@use{\zwu@keywords@en}{, }%
}
\newenvironment{abstract}{%
  \zwusetup{language=chinese}%
  \zwu@chapter{摘要}%
}{
  \par\null\par\noindent\hangindent=4\ccwd\relax
  \textbf{关键词}：\zwu@keywords@text\par
  \zwu@reset@main@language
}

\newbox\zwu@keywords@box
\newlength\zwu@keywords@width

% 英文摘要环境
\newenvironment{abstract*}{%
  \zwusetup{language=english}%
    \begingroup
      % 本科生的英文摘要使用小二号衬线体
      \ctexset{chapter/format=\centering\fontsize{18bp}{33bp}\selectfont}%
      \zwu@chapter{ABSTRACT}%
    \endgroup
}{
  \par\null\par\noindent
  \savebox\zwu@keywords@box{\textbf{Key Words}: }%
  \zwu@keywords@width=\linewidth
  \advance\zwu@keywords@width-\wd\zwu@keywords@box
  \textbf{Key Words}: \parbox[t]{\zwu@keywords@width}{\zwu@keywords@en@text\par}\par
  \zwu@reset@main@language
}

% Reserved for compatibility until 2020-07-01.
\newenvironment{enabstract}{%
  \begin{abstract*}%
}{%
  \end{abstract*}%
}


% \subsection{目录}

% 研究生规定目录另面起；
% 本科生规定从目录开始编页码，所以必须另页起。
\renewcommand\tableofcontents{%
    \cleardoublepage
    \pagenumbering{arabic}%
    \pagestyle{plain}%
  \zwu@chapter{\contentsname}%
  \@starttoc{toc}%
}

% 下面用 \pkg{titletoc} 宏包设置目录内容的格式。
% 先定义目录线：
\newcommand\zwu@leaders{%
  \hspace{2bp}%
  \titlerule*[4bp]{\textperiodcentered}%
  \hspace{2bp}%
}

\contentsmargin{0bp}

% 各章目录要求宋体 14 磅，单倍行距，段前 6 磅，段后 0 磅，两端对齐，
% 页码右对齐，章序号与章名间空一字。
% 但是 Word 模板中实际是行距 20 磅。
  \titlecontents{chapter}
    [\z@]{\normalsize}
    {\contentspush{\thecontentslabel\unskip\hspace{\ccwd}}}{}
    {\zwu@leaders\thecontentspage}
  \titlecontents{section}
    [\ccwd]{\normalsize}
    {\contentspush{\thecontentslabel\hspace{\ccwd}}}{}
    {\zwu@leaders\thecontentspage}
  \titlecontents{subsection}
    [2\ccwd]{\normalsize}
    {\contentspush{\thecontentslabel
      \ifzwu@section@style@arabic\hspace{\ccwd}\else 、\fi}}{}
    {\zwu@leaders\thecontentspage}


% 本科生要求目录中正文每章前多空一行，而目录、附录等章则不需要空行，
% 所以不能简单判断 \cs{if@mainmatter}，需要重新定义 \cs{mainmatter} 等命令。
\newif\ifzwu@addtocspace
\ifzwu@degree@bachelor
  \zwu@addtocspacetrue
  \g@addto@macro\frontmatter{\zwu@addtocspacefalse}%
  \g@addto@macro\mainmatter{\zwu@addtocspacetrue}%
  \g@addto@macro\backmatter{\zwu@addtocspacefalse}%
  \g@addto@macro\appendix{\zwu@addtocspacefalse}%
\fi

% 处理本科生在目录中添加空行。
\renewcommand\chapter{%
  \if@openright\cleardoublepage\else\clearpage\fi
  \thispagestyle{\CTEX@chapter@pagestyle}%
  \global\@topnum\z@
  \@afterindenttrue
  \ifzwu@degree@bachelor
    \ifzwu@addtocspace
      \addtocontents{toc}{\protect\addvspace{12bp}}%
    \fi
  \fi
  \secdef\@chapter\@schapter
}

% 研究生要求图、表的清单须另页起。
\newlength{\zwu@lof@label@width}
\newcommand\zwu@set@lof@format{%
  \settowidth{\zwu@lof@label@width}{\figurename~9.99}%
  \addtolength{\zwu@lof@label@width}{1em}%
  \titlecontents{figure}%
    [\zwu@lof@label@width]{\normalsize}%
    {\contentslabel[\figurename~\thecontentslabel]{\zwu@lof@label@width}}{}%
    {\zwu@leaders\thecontentspage}%
  \titlecontents{table}%
    [\zwu@lof@label@width]{\normalsize}%
    {\contentslabel[\tablename~\thecontentslabel]{\zwu@lof@label@width}}{}%
    {\zwu@leaders\thecontentspage}%
}
\zwu@set@lof@format
\zwu@option@hook{main-language}{\zwu@set@lof@format}
\renewcommand\listoffigures{%
  \zwu@chapter{\listfigurename}%
  \@starttoc{lof}%
}
\renewcommand\listoftables{%
  \zwu@chapter{\listtablename}%
  \@starttoc{lot}%
}


% \subsection{符号说明}

% 研究生规定符号说明另页起，标题字体字号等同论文正文，
% 《撰写手册》第 9 页 1.10(2) 还规定“符号说明不加页码”。
%\newenvironment{notation}{%
%  \zwu@chapter{\zwu@notation@name}%
%}%
%\newcommand*\notationlabel[1]{#1\hfil}%
%\newenvironment{notationlist}[1]{%
%  \list{}{%
%    \itemsep 3bp%
%    \labelwidth #1\relax%
%    \labelsep 1em%
%    \leftmargin\labelwidth
%    \advance\leftmargin\labelsep
%    \advance\leftmargin 3em%
%    \rightmargin 3em%
%    \let\makelabel\notationlabel
%  }%
%}{%
%  \endlist
%}


% \subsection{正文}

% \cs{sloppy} 可以减少“overfull boxes”。
\sloppy

% 禁止扩大段间距。（\href{https://github.com/zwutug/zwuthesis/issues/209}{
%   zwutug/zwuthesis\#209}）
\raggedbottom

% 段间距 0 磅。
\setlength{\parskip}{\z@}

% 首段缩进。
\ctexset{autoindent=2}

% 首段缩进。
\let\@afterindentfalse\@afterindenttrue
\@afterindenttrue

% URL 的字体设为保持原样。
\urlstyle{same}

% 使用 \pkg{xurl} 宏包的方法，增加 URL 可断行的位置。
\def\UrlBreaks{%
  \do\/%
  \do\a\do\b\do\c\do\d\do\e\do\f\do\g\do\h\do\i\do\j\do\k\do\l%
     \do\m\do\n\do\o\do\p\do\q\do\r\do\s\do\t\do\u\do\v\do\w\do\x\do\y\do\z%
  \do\A\do\B\do\C\do\D\do\E\do\F\do\G\do\H\do\I\do\J\do\K\do\L%
     \do\M\do\N\do\O\do\P\do\Q\do\R\do\S\do\T\do\U\do\V\do\W\do\X\do\Y\do\Z%
  \do0\do1\do2\do3\do4\do5\do6\do7\do8\do9\do=\do/\do.\do:%
  \do\*\do\-\do\~\do\'\do\"\do\-}
\Urlmuskip=0mu plus 0.1mu

% 脚注用带圈的数字：
\renewcommand\thefootnote{\zwu@textcircled{footnote}}

% LaTeX 默认脚注按章计数，即每章的开始才重置脚注计数器；我们修改为按页计数。
% 简单的|\@addtoreset{footnote}{page}|并不可靠，
% \footnote{\url{https://texfaq.org/FAQ-footnpp.html}}
% 所以我们使用 \pkg{footmisc} 宏包。

% 脚注线长为版心宽度的四分之一：
\renewcommand\footnoterule{%
  \kern-3\p@
  \hrule\@width.25\textwidth
  \kern2.6\p@}
  %
  % 注文缩进两字：
\renewcommand\@makefntext[1]{%
  \parindent 2\ccwd\relax
  \noindent
  \hb@xt@2\ccwd{\hss\@makefnmark}#1}


% \subsection{列表}
% \label{sec:list}

% 调整列表中各项之间过大的间距。
\setlength\partopsep{\z@}
\newcommand\zwu@nolistsep{%
  \parsep 0\p@ \@plus.2\p@
  \topsep 0\p@ \@plus.2\p@
  \itemsep0\p@ \@plus.2\p@
}
\def\@listi{\leftmargin\leftmargini
            \zwu@nolistsep}
\let\@listI\@listi
\@listi
\def\@listii {\leftmargin\leftmarginii
              \labelwidth\leftmarginii
              \advance\labelwidth-\labelsep
              \zwu@nolistsep}
\def\@listiii{\leftmargin\leftmarginiii
              \labelwidth\leftmarginiii
              \advance\labelwidth-\labelsep
              \zwu@nolistsep}


% \subsection{浮动体}

% \LaTeX{} 对放置浮动体的要求比较强，这里按照 UK TeX FAQ 的建议
% \footnote{\url{https://texfaq.org/FAQ-floats}} 对其适当放宽。
\renewcommand\topfraction{.85}
\renewcommand\bottomfraction{.7}
\renewcommand\textfraction{.15}
\renewcommand\floatpagefraction{.66}
\renewcommand\dbltopfraction{.66}
\renewcommand\dblfloatpagefraction{.66}
\setcounter{topnumber}{9}
\setcounter{bottomnumber}{9}
\setcounter{totalnumber}{20}
\setcounter{dbltopnumber}{9}

% 修改默认的浮动体描述符为 |h|。
\def\fps@figure{h}
\def\fps@table{h}

% 用 \pkg{caption} 宏包设置图、表的格式：

% 图号、图题置于图的下方，宋体 10.5 磅居中，单倍行距，段前 6 磅，段后 12 磅，
% 图号与图题文字之间空一字，图号、图题加粗。
% 图注位于图的下方，左缩进两字，续行悬挂缩进左对齐，两端对齐。

% 表号、表题置于表的上方，黑体 10.5 磅居中，单倍行距，段前 6 磅，段后 6 磅，
% 表号与表题文字之间空一字，表号、表题加粗。
% 表注左缩进两字，续行悬挂缩进左对齐，两端对齐。
\setlength{\floatsep}{6bp}
\setlength{\textfloatsep}{6bp}
\setlength{\intextsep}{6bp}

\DeclareCaptionFont{zwu}{%
  \ifzwu@language@chinese
    \fontsize{10.5bp}{13.65bp}\selectfont
  \else
    \fontsize{10.5bp}{12.075bp}\selectfont
  \fi
}

\captionsetup{
  font           = zwu,
  labelsep       = quad,
  skip           = 6bp,
  figureposition = bottom,
  tableposition  = top,
}
\captionsetup[figure]{
  belowskip = 6bp,
}

% 由于 LaTeX2e kernel 的问题，图表等浮动体与文字前后的距离不一致，需要进行 patch。
% 参考 \href{https://github.com/tuna/thuthesis/issues/614}{tuna/thuthesis/issues\#614}、
% \url{https://www.zhihu.com/question/46618031} 和
% \url{https://tex.stackexchange.com/a/40363/82731}。
%    \begin{macrocode}
\patchcmd{\@addtocurcol}%
  {\vskip \intextsep}%
  {\edef\save@first@penalty{\the\lastpenalty}\unpenalty
   \ifnum \lastpenalty = \@M  % hopefully the OR penalty
     \unpenalty
   \else
     \penalty \save@first@penalty \relax % put it back
   \fi
   \ifnum\outputpenalty <-\@Mii
     \addvspace\intextsep
     \vskip\parskip
   \else
     \addvspace\intextsep
   \fi}%
  {}{\zwu@patch@error{\@addtocurcol}}
\patchcmd{\@addtocurcol}%
  {\vskip\intextsep \ifnum\outputpenalty <-\@Mii \vskip -\parskip\fi}%
  {\ifnum\outputpenalty <-\@Mii
     \aftergroup\vskip\aftergroup\intextsep
     \aftergroup\nointerlineskip
   \else
     \vskip\intextsep
   \fi}%
  {}{\zwu@patch@error{\@addtocurcol}}
\patchcmd{\@getpen}{\@M}{\@Mi}
  {}{\zwu@patch@error{\@getpen}}

% 新定义了 \cs{note} 来生成图表的附注。
% 如果用 \cs{caption} 生成图表的附注会导致图表的序号有误；
% 如果用 \cs{bicaption} 会导致表注无法置于表后，而且对齐方式不对。
\newcommand\note[1]{%
  \begingroup
    \captionsetup{
      font          = zwu,
      margin        = 2\ccwd,
      position      = bottom,
    }%
    \caption*{#1}%
  \endgroup
}

% 表格默认字号略小
\patchcmd\@floatboxreset{%
  \normalsize
}{%
  \small
}{}{\zwu@patch@error{\@floatboxreset}}

% 对 \pkg{longtable} 跨页表格进行相同的设置。
%
% 在 Word 模板中按照正确的设置（需要去掉文档网格），
% 中文模板每页能装下 1 行标题、1 行表头、30 行表身，
% 英文模板每页能装下 1 行标题、1 行表头、33 行表身。
%    \begin{macrocode}
\AtEndOfPackageFile*{longtable}{
  \AtBeginEnvironment{longtable}{%
    \ifdim\f@size pt > 12pt\relax
      \small
    \fi
  }
}


% \subsection{参考文献}

\PassOptionsToPackage{compress}{natbib}

\AtEndOfPackageFile*{natbib}{
  % 定义几种引用文献的标注样式。
  \newcommand\bibstyle@super{\bibpunct{[}{]}{,}{s}{,}{\textsuperscript{,}}}
  \newcommand\bibstyle@inline{\bibpunct{[}{]}{,}{n}{,}{,}}
  \newcommand\bibstyle@authoryear{\bibpunct{(}{)}{;}{a}{,}{,}}
  \@namedef{bibstyle@author-year}{\bibstyle@authoryear}
  %
  % 几种种引用样式，与 \file{bst} 文件名保持一致，
  % 这样在使用 \cs{bibliographystyle} 选择参考文献表的样式时也会设置对应的引用样式。
  \@namedef{bibstyle@zwuthesis-numerical}{\bibstyle@super}
  \@namedef{bibstyle@zwuthesis-authoryear}{\bibstyle@authoryear}
  \@namedef{bibstyle@zwuthesis-bachelor}{\bibstyle@super}
  %
  % 如果载入 `natbib` 前设置了 `cite-style`，这里先进行配置。
  % https://github.com/zwutug/zwuthesis/issues/327
  \ifx\zwu@cite@style\@empty\else
    \citestyle{\zwu@cite@style}%
  \fi
  %
  % 定义接口 cite-style 切换引用样式。
  \zwu@option@hook{cite-style}{%
    \citestyle{\zwu@cite@style}%
  }
  %
  % 如果文献序号作为叙述文字的一部分，需要临时将文献序号与正文平排
  \DeclareRobustCommand\inlinecite{\@inlinecite}
  \def\@inlinecite#1{\begingroup\let\@cite\NAT@citenum\citep{#1}\endgroup}
  %
  % 修改引用的样式。
  % 这里在 filehook 中无法使用 \cs{patchcmd}，所以只能手动重定义。
  %
  % 将 super 式 \cs{citep} 引用的页码置于括号外。
  \renewcommand\NAT@citesuper[3]{%
    \ifNAT@swa
      \if*#2*\else
        #2\NAT@spacechar
      \fi
      % \unskip\kern\p@\textsuperscript{\NAT@@open#1\NAT@@close}%
      %  \if*#3*\else\NAT@spacechar#3\fi\else #1\fi\endgroup}
      \unskip\kern\p@
      \textsuperscript{%
        \NAT@@open#1\NAT@@close
        \if*#3*\else#3\fi
      }%
      \kern\p@
    \else
      #1%
    \fi
    \endgroup
  }
  %
  % 将 numbers 式 \cs{citep} 引用的页码置于括号外并改为上标。
  \renewcommand\NAT@citenum[3]{%
    \ifNAT@swa
      \NAT@@open
      \if*#2*\else
        #2\NAT@spacechar
      \fi
      % #1\if*#3*\else\NAT@cmt#3\fi\NAT@@close
      #1\NAT@@close
      \if*#3*\else
        \textsuperscript{#3}%
      \fi
    \else
      #1%
    \fi
    \endgroup
  }
  %
  % 在 filehook 中无法使用 \cs{patchcmd}，所以只能手动重定义。
  \def\NAT@citexnum[#1][#2]#3{%
    \NAT@reset@parser
    \NAT@sort@cites{#3}%
    \NAT@reset@citea
    \@cite{\def\NAT@num{-1}\let\NAT@last@yr\relax\let\NAT@nm\@empty
      \@for\@citeb:=\NAT@cite@list\do
      {\@safe@activestrue
      \edef\@citeb{\expandafter\@firstofone\@citeb\@empty}%
      \@safe@activesfalse
      \@ifundefined{b@\@citeb\@extra@b@citeb}{%
        {\reset@font\bfseries?}
          \NAT@citeundefined\PackageWarning{natbib}%
        {Citation `\@citeb' on page \thepage \space undefined}}%
      {\let\NAT@last@num\NAT@num\let\NAT@last@nm\NAT@nm
        \NAT@parse{\@citeb}%
        \ifNAT@longnames\@ifundefined{bv@\@citeb\@extra@b@citeb}{%
          \let\NAT@name=\NAT@all@names
          \global\@namedef{bv@\@citeb\@extra@b@citeb}{}}{}%
        \fi
        \ifNAT@full\let\NAT@nm\NAT@all@names\else
          \let\NAT@nm\NAT@name\fi
        \ifNAT@swa
        \@ifnum{\NAT@ctype>\@ne}{%
          \@citea
          \NAT@hyper@{\@ifnum{\NAT@ctype=\tw@}{\NAT@test{\NAT@ctype}}{\NAT@alias}}%
        }{%
          \@ifnum{\NAT@cmprs>\z@}{%
          \NAT@ifcat@num\NAT@num
            {\let\NAT@nm=\NAT@num}%
            {\def\NAT@nm{-2}}%
          \NAT@ifcat@num\NAT@last@num
            {\@tempcnta=\NAT@last@num\relax}%
            {\@tempcnta\m@ne}%
          \@ifnum{\NAT@nm=\@tempcnta}{%
            \@ifnum{\NAT@merge>\@ne}{}{\NAT@last@yr@mbox}%
          }{%
            \advance\@tempcnta by\@ne
            \@ifnum{\NAT@nm=\@tempcnta}{%
              % 在顺序编码制下，\pkg{natbib} 只有在三个以上连续文献引用才会使用连接号，
              % 这里修改为允许两个引用使用连接号。
              % 参考 https://tex.stackexchange.com/a/86991/82731 。
              %
              % \ifx\NAT@last@yr\relax
              %   \def@NAT@last@yr{\@citea}%
              % \else
              %   \def@NAT@last@yr{--\NAT@penalty}%
              % \fi
              \def@NAT@last@yr{-\NAT@penalty}%
            }{%
              \NAT@last@yr@mbox
            }%
          }%
          }{%
          \@tempswatrue
          \@ifnum{\NAT@merge>\@ne}{\@ifnum{\NAT@last@num=\NAT@num\relax}{\@tempswafalse}{}}{}%
          \if@tempswa\NAT@citea@mbox\fi
          }%
        }%
        \NAT@def@citea
        \else
          \ifcase\NAT@ctype
            \ifx\NAT@last@nm\NAT@nm \NAT@yrsep\NAT@penalty\NAT@space\else
              \@citea \NAT@test{\@ne}\NAT@spacechar\NAT@mbox{\NAT@super@kern\NAT@@open}%
            \fi
            \if*#1*\else#1\NAT@spacechar\fi
            \NAT@mbox{\NAT@hyper@{{\citenumfont{\NAT@num}}}}%
            \NAT@def@citea@box
          \or
            \NAT@hyper@citea@space{\NAT@test{\NAT@ctype}}%
          \or
            \NAT@hyper@citea@space{\NAT@test{\NAT@ctype}}%
          \or
            \NAT@hyper@citea@space\NAT@alias
          \fi
        \fi
      }%
      }%
        \@ifnum{\NAT@cmprs>\z@}{\NAT@last@yr}{}%
        \ifNAT@swa\else
          % 将 numerical 式 \cs{citet} 引用的页码置于括号外并改为上标。
          %
          % \@ifnum{\NAT@ctype=\z@}{%
          %   \if*#2*\else\NAT@cmt#2\fi
          % }{}%
          \NAT@mbox{\NAT@@close}%
          \@ifnum{\NAT@ctype=\z@}{%
            \if*#2*\else
              \textsuperscript{#2}%
            \fi
          }{}%
          \NAT@super@kern
        \fi
    }{#1}{#2}%
  }%
  %
  % 将 author-year 式 \cs{citep} 引用的页码置于括号外并改为上标：
  \renewcommand\NAT@cite%
      [3]{\ifNAT@swa\NAT@@open\if*#2*\else#2\NAT@spacechar\fi
          % #1\if*#3*\else\NAT@cmt#3\fi\NAT@@close\else#1\fi\endgroup}
          #1\NAT@@close\if*#3*\else\textsuperscript{#3}\fi\else#1\fi\endgroup}
  %
  % 调整 author-year 式 \cs{citet} 引用的页码。
  \def\NAT@citex%
    [#1][#2]#3{%
    \NAT@reset@parser
    \NAT@sort@cites{#3}%
    \NAT@reset@citea
    \@cite{\let\NAT@nm\@empty\let\NAT@year\@empty
      \@for\@citeb:=\NAT@cite@list\do
      {\@safe@activestrue
      \edef\@citeb{\expandafter\@firstofone\@citeb\@empty}%
      \@safe@activesfalse
      \@ifundefined{b@\@citeb\@extra@b@citeb}{\@citea%
        {\reset@font\bfseries ?}\NAT@citeundefined
                  \PackageWarning{natbib}%
        {Citation `\@citeb' on page \thepage \space undefined}\def\NAT@date{}}%
      {\let\NAT@last@nm=\NAT@nm\let\NAT@last@yr=\NAT@year
        \NAT@parse{\@citeb}%
        \ifNAT@longnames\@ifundefined{bv@\@citeb\@extra@b@citeb}{%
          \let\NAT@name=\NAT@all@names
          \global\@namedef{bv@\@citeb\@extra@b@citeb}{}}{}%
        \fi
      \ifNAT@full\let\NAT@nm\NAT@all@names\else
        \let\NAT@nm\NAT@name\fi
      \ifNAT@swa\ifcase\NAT@ctype
        \if\relax\NAT@date\relax
          \@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}\NAT@date}%
        \else
          \ifx\NAT@last@nm\NAT@nm\NAT@yrsep
              \ifx\NAT@last@yr\NAT@year
                \def\NAT@temp{{?}}%
                \ifx\NAT@temp\NAT@exlab\PackageWarningNoLine{natbib}%
                {Multiple citation on page \thepage: same authors and
                year\MessageBreak without distinguishing extra
                letter,\MessageBreak appears as question mark}\fi
                \NAT@hyper@{\NAT@exlab}%
              \else\unskip\NAT@spacechar
                \NAT@hyper@{\NAT@date}%
              \fi
          \else
            \@citea\NAT@hyper@{%
              \NAT@nmfmt{\NAT@nm}%
              \hyper@natlinkbreak{%
                \NAT@aysep\NAT@spacechar}{\@citeb\@extra@b@citeb
              }%
              \NAT@date
            }%
          \fi
        \fi
      \or\@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
      \or\@citea\NAT@hyper@{\NAT@date}%
      \or\@citea\NAT@hyper@{\NAT@alias}%
      \fi \NAT@def@citea
      \else
        \ifcase\NAT@ctype
          \if\relax\NAT@date\relax
            \@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
          \else
          \ifx\NAT@last@nm\NAT@nm\NAT@yrsep
              \ifx\NAT@last@yr\NAT@year
                \def\NAT@temp{{?}}%
                \ifx\NAT@temp\NAT@exlab\PackageWarningNoLine{natbib}%
                {Multiple citation on page \thepage: same authors and
                year\MessageBreak without distinguishing extra
                letter,\MessageBreak appears as question mark}\fi
                \NAT@hyper@{\NAT@exlab}%
              \else
                \unskip\NAT@spacechar
                \NAT@hyper@{\NAT@date}%
              \fi
          \else
            \@citea\NAT@hyper@{%
              \NAT@nmfmt{\NAT@nm}%
              \hyper@natlinkbreak{\NAT@spacechar\NAT@@open\if*#1*\else#1\NAT@spacechar\fi}%
                {\@citeb\@extra@b@citeb}%
              \NAT@date
            }%
          \fi
          \fi
        \or\@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
        \or\@citea\NAT@hyper@{\NAT@date}%
        \or\@citea\NAT@hyper@{\NAT@alias}%
        \fi
        \if\relax\NAT@date\relax
          \NAT@def@citea
        \else
          \NAT@def@citea@close
        \fi
      \fi
      }}\ifNAT@swa\else
        % 将 author-year 式 \cs{citet} 引用的页码置于括号外并改为上标。
        %
        % \if*#2*\else\NAT@cmt#2\fi
        \if\relax\NAT@date\relax\else\NAT@@close\fi
        \if*#2*\else\textsuperscript{#2}\fi
      \fi}{#1}{#2}}
  %
  % 为了将参考文献加入目录和 pdf 书签，重新定义 \pkg{natbib} 的 \cmd{bibsection}
  % 另外如果调用了 \pkg{chapterbib} 或者使用了 \opt{sectionbib} 参数，
  % 需要使用节标题 \cs{section}。
  \newcommand\zwu@bib@chapter{%
    \@mainmatterfalse
    \chapter{\bibname}%
  }%
  \newcommand\zwu@bib@section{%
    \begingroup
      \ctexset{section/numbering=false}%
      \section{\bibname}%
    \endgroup
  }%
  \@ifpackagewith{chapterbib}{sectionbib}{%
    \zwu@error{The "sectionbib" option cannot be used with chaperbib if natbib loaded}%
  }{}%
  \@ifpackageloaded{chapterbib}{%
    \let\bibsection\zwu@bib@section
  }{%
    \@ifxundefined\NAT@sectionbib{%
      \let\bibsection\zwu@bib@chapter
    }{%
      \let\bibsection\zwu@bib@section
    }%
  }%
  %
  % 参考文献列表格式：宋体 10.5 磅，行距 20 磅，续行缩进两字，左对齐。
  % 本科生依然是小四宋体。
  \renewcommand\bibfont{%
    \normalsize
  }
  \setlength{\bibsep}{0\p@ \@plus.2\p@}
  \renewcommand\@biblabel[1]{[#1]\hfill}
  \setlength{\bibhang}{2\ccwd}
}


% biblatex 宏包的配置

\AtEndOfPackageFile*{biblatex}{
  \DeclareRobustCommand\inlinecite{\parencite}
  \defbibheading{bibliography}[\bibname]{%
    \@mainmatterfalse
    \chapter{\bibname}%
  }
  \renewcommand\bibfont{%
    \fontsize{10.5bp}{20bp}\selectfont
  }
  \setlength{\bibitemsep}{0\p@ \@plus.2\p@}
  \setlength{\bibhang}{2\ccwd}
}

% \subsection{附录}

% 定义了一个满足要求的致谢环境：
\newenvironment{acknowledgements}{%
  \@mainmatterfalse
  \chapter{\zwu@acknowledgements@name}%
}{
  \ifzwu@degree@bachelor
    \par
    \null\par
    \begingroup
      \raggedleft
      \zwu@date@zh@short\par
    \endgroup
  \fi
}


% 兼容旧版本中“acknowledgments”的拼法。
% Reserved for compatibility until 2020-07-01.
\newenvironment{acknowledgments}{%
  \begin{acknowledgements}%
}{%
  \end{acknowledgements}%
}


% \subsection{其他宏包的设置}

% 这些宏包并非格式要求，但是为了方便同学们使用，在这里进行简单设置。


% \subsubsection{\pkg{hyperref} 宏包}

\AtEndOfPackageFile*{hyperref}{
  \hypersetup{
    bookmarksnumbered  = true,
    bookmarksopen      = true,
    bookmarksopenlevel = 1,
    linktoc            = all,
    unicode            = true,
    psdextra           = true,
  }
  %
  % 如果为 \opt{pdf} 样式，设置 hyperlink 颜色
  \hypersetup{hidelinks}
  %
  % 填写 PDF 元信息。
  \AtBeginDocument{%
    \hypersetup{
      pdftitle  = \zwu@title,
      pdfauthor = \zwu@author,
    }%
  }
  %
  % 添加 PDF 书签
  %
  \newcounter{zwu@bookmarknumber}
  \renewcommand\zwu@pdfbookmark[1]{%
    \phantomsection
    \stepcounter{zwu@bookmarknumber}%
    \pdfbookmark[0]{#1}{zwuchapter.\thezwu@bookmarknumber}%
  }
  %
  % 在 PDF 字符串中去掉换行，以减少 \pkg{hyperref} 的警告信息。
  \pdfstringdefDisableCommands{
    \let\\\@empty
    \let\hspace\@gobble
  }
  %
  % \pkg{hyperref} 与 \pkg{unicode-math} 存在一些兼容性问题，见
  % \href{https://github.com/zwutug/zwuthesis/issues/223}{%
  %   zwutug/zwuthesis\#223}，
  % \href{https://github.com/ho-tex/hyperref/pull/90}{ho-tex/hyperref\#90} 和
  % \href{https://github.com/zwutug/zwuthesis/issues/235}{%
  %   zwutug/zwuthesis/\#235}。
  \@ifpackagelater{hyperref}{2019/04/27}{}{%
    \g@addto@macro\psdmapshortnames{\let\mu\textmu}%
  }
  %
  % 设置中文的 \cs{autoref}。
  % \footnote{\url{https://tex.stackexchange.com/a/66150/82731}}
  \ifzwu@language@chinese
    \def\equationautorefname~#1\null{公式~(#1)\null}
    \def\footnoteautorefname{脚注}
    \def\itemautorefname~#1\null{第~#1~项\null}
    \def\figureautorefname{图}
    \def\tableautorefname{表}
    \def\partautorefname~#1\null{第~#1~部分\null}
    \def\appendixautorefname{附录}
    \def\chapterautorefname~#1\null{#1.~\null}
    \def\sectionautorefname~#1\null{第~#1~节\null}
    \def\subsectionautorefname~#1\null{第~#1~小节\null}
    \def\subsubsectionautorefname~#1\null{第~#1~小小节\null}
    \def\paragraphautorefname~#1\null{第~#1~段\null}
    \def\subparagraphautorefname~#1\null{第~#1~小段\null}
    \def\theoremautorefname{定理}
    \def\HyRef@autopageref#1{\hyperref[{#1}]{第~\pageref*{#1} 页}}
  \fi
  %
  % 本科生需要在 \tableofcontents 处切换 \pagenumbering，
  % 在使用了 notoccite 后会导致 PDF 书签的页码有误（#293），
  % 所以需要补充 https://tex.stackexchange.com/a/593839/82731 的 patch。
  % LuaTeX 不需要这个 patch。
  \ifXeTeX
    \def\HyPL@StorePageLabel#1{%
      \begingroup
        \edef\Hy@tempa{\the\Hy@abspage<<#1>>}%
        \immediate\write\@mainaux{%
          \string\HyPL@Entry{\Hy@tempa}%
        }%
      \endgroup
    }
  \fi
}


% \subsubsection{\pkg{amsthm} 宏包}

\AtEndOfPackageFile*{amsthm}{
  \newtheoremstyle{zwuplain}
    {}{}
    {}{2\ccwd}
    {\bfseries}{}
    {\ccwd}{}
  \theoremstyle{zwuplain}
  % 定义新的定理
  \ifzwu@language@chinese
    \newcommand\zwu@assertion@name{断言}
    \newcommand\zwu@assumption@name{假设}
    \newcommand\zwu@axiom@name{公理}
    \newcommand\zwu@corollary@name{推论}
    \newcommand\zwu@definition@name{定义}
    \newcommand\zwu@example@name{例}
    \newcommand\zwu@lemma@name{引理}
    \newcommand\zwu@proof@name{证明}
    \newcommand\zwu@proposition@name{命题}
    \newcommand\zwu@remark@name{注}
    \newcommand\zwu@theorem@name{定理}
  \else
    \newcommand\zwu@assertion@name{Assertion}
    \newcommand\zwu@assumption@name{Assumption}
    \newcommand\zwu@axiom@name{Axiom}
    \newcommand\zwu@corollary@name{Corollary}
    \newcommand\zwu@definition@name{Definition}
    \newcommand\zwu@example@name{Example}
    \newcommand\zwu@lemma@name{Lemma}
    \newcommand\zwu@proof@name{Proof}
    \newcommand\zwu@proposition@name{Proposition}
    \newcommand\zwu@remark@name{Remark}
    \newcommand\zwu@theorem@name{Theorem}
  \fi
  \newtheorem{theorem}             {\zwu@theorem@name}    [chapter]
  \newtheorem{assertion}  [theorem]{\zwu@assertion@name}
  \newtheorem{axiom}      [theorem]{\zwu@axiom@name}
  \newtheorem{corollary}  [theorem]{\zwu@corollary@name}
  \newtheorem{lemma}      [theorem]{\zwu@lemma@name}
  \newtheorem{proposition}[theorem]{\zwu@proposition@name}
  \newtheorem{assumption}          {\zwu@assumption@name} [chapter]
  \newtheorem{definition}          {\zwu@definition@name} [chapter]
  \newtheorem{example}             {\zwu@example@name}    [chapter]
  \newtheorem*{remark}             {\zwu@remark@name}
  % \pkg{amsthm} 单独定义了 proof 环境，这里重新定义以满足格式要求。
  % 原本模仿 \pkg{amsthm} 写成 |\item[\hskip\labelsep\hskip2\ccwd #1\hskip\ccwd]|，
  % 但是却会多出一些间隙。
  \renewenvironment{proof}[1][\zwu@proof@name]{\par
    \pushQED{\qed}%
    \normalfont \topsep6\p@\@plus6\p@\relax
    \trivlist
      \item\relax\hskip2\ccwd
      \textbf{#1}
      \hskip\ccwd\ignorespaces
    }{%
    \popQED\endtrivlist\@endpefalse
  }
  \renewcommand\qedsymbol{\zwu@qed}
}


% \subsubsection{\pkg{algorithm2e} 宏包}

% 按章节编号。
\PassOptionsToPackage{algochapter}{algorithm2e}

\AtEndOfPackageFile*{algorithm2e}{
  \ifzwu@language@chinese
    \SetAlgorithmName{算法}{算法}{算法清单}
  \else
    \SetAlgorithmName{Algorithm}{Algorithm}{List of Algorithms}
  \fi
  %
  % 设置算法环境的格式。
  \SetAlCapSkip{6bp}
  \SetAlCapFnt{\small}
  \SetAlCapNameFnt{\small}
  \SetAlCapNameSty{textbf}
  \SetAlgoCaptionSeparator{\unskip\hspace*{\ccwd}}
  %
  % 设置算法清单的格式
  \renewcommand\listofalgocfs{%
    \zwu@chapter{\listalgorithmcfname}%
    \@starttoc{loa}%
  }
  \titlecontents{algocf}
    [2.3em]{\normalsize}
    {\contentslabel{2.3em}}{}
    {\zwu@leaders\contentspage}
  \contentsuse{algocf}{loa}
}


% \subsubsection{\pkg{mathtools} 宏包}

% \pkg{mathtools} 会修改 \pkg{unicode-math} 的 `\underbrace` 和 `\overbrace`，
% 需要还原为 `\LaTeXunderbrace` 和 `\LaTeXoverbrace`，
% 参考 \url{https://tex.stackexchange.com/q/521394/82731}。
\AtEndOfPackageFile*{mathtools}{
  \@ifpackageloaded{unicode-math}{
    \let\underbrace\LaTeXunderbrace
    \let\overbrace\LaTeXoverbrace
  }{}
}

% \subsubsection{\pkg{nomencl} 宏包}

\AtEndOfPackageFile*{nomencl}{
  \let\nomname\zwu@notation@name
  \def\thenomenclature{%
    \pagestyle{headings}%
    \zwu@chapter{\zwu@notation@name}%
    \nompreamble
    \list{}{%
      \labelwidth\nom@tempdim
      \leftmargin\labelwidth
      \advance\leftmargin\labelsep
      \itemsep\nomitemsep
      \let\makelabel\nomlabel}}
  \def\endthenomenclature{%
    \endlist
    \nompostamble
    \clearpage
    \pagestyle{plain}%
  }
}


% \subsubsection{\pkg{siunitx} 宏包}

\AtEndOfPackageFile*{siunitx}{
  \newcommand\zwu@set@siunitx@language{%
    \ifzwu@language@chinese
      \sisetup{
        list-final-separator = { 和~},
        list-pair-separator  = { 和 },
        range-phrase         = {～},
      }%
    \else
      \sisetup{
        list-final-separator = {, and },
        list-pair-separator  = { and },
        range-phrase         = { to },
      }%
    \fi
  }
  \zwu@set@siunitx@language
  \zwu@option@hook{language}{\zwu@set@siunitx@language}
}

% \subsubsection{\pkg{chapterbib} 宏包}

\AtEndOfPackageFile*{chapterbib}{
  \@ifpackageloaded{natbib}{%
    \@ifpackagewith{chapterbib}{sectionbib}{%
      \zwu@error{The "sectionbib" option cannot be used with chaperbib if natbib loaded}%
    }{}%
    \renewcommand\bibsection{%
      \begingroup
        \ctexset{section/numbering=false}%
        \section{\bibname}%
      \endgroup
    }
  }{}
}
