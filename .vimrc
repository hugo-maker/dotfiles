" initialize all settings
set all&

set encoding=utf-8
scriptencoding utf-8
" 1. ファイル読み込み時の文字コードの設定
" 2. Vim scriptでマルチバイト文字を使う場合の設定

" 保存時の文字コード
set fileencoding=utf-8
" 読み込み時の文字コードの自動判別, 左側が優先
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932,latin1
" 改行コードの自動判別, 左側が優先
set fileformats=unix,dos,mac
" マルチバイト文字や記号(□や○)が崩れるのを防ぐ
set ambiwidth=double

filetype plugin on

" enable the plugin matchit
runtime macros/matchit.vim
" enable the plugin man
" カーソル位置の単語のmanを別windowで開く <leader>(default は \) K
runtime! ftplugin/man.vim

syntax enable
colorscheme iceberg

" transparent background
augroup TransparentBG
  autocmd!
  autocmd Colorscheme * highlight Normal ctermbg=None
  autocmd Colorscheme * highlight NonText ctermbg=None
  autocmd Colorscheme * highlight LineNr ctermbg=None
  autocmd Colorscheme * highlight Folded ctermbg=None
  autocmd Colorscheme * highlight EndOfBuffer ctermbg=None 
augroup END

" auto reload .vimrc
augroup source-vimrc
  autocmd!
  autocmd BufWritePost *vimrc source $MYVIMRC | set foldmethod=marker
  autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

" auto comment off
augroup auto_comment_off
  autocmd!
  autocmd BufEnter * setlocal formatoptions-=r
  autocmd BufEnter * setlocal formatoptions-=o
augroup END

" カーソル位置の記憶
augroup vimrcEx
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
augroup END

"----------set----------
set number
set title

" エラービープ音の全停止"
set visualbell t_vb=
set noerrorbells

" 画面端ではなく5行余裕を持たせてスクロールする"
set scrolloff=5

" 短形選択中<C-v> は行末にテキストがなくてもカーソルを行末以降に移動可能に
set virtualedit+=block

"----------buffer---------
set hidden

" command characters shown in statusline
set showcmd
" the last window always have status line
set laststatus=2
" set the command window height to 2 lines
set cmdheight=2

"----------search----------
set incsearch
set ignorecase
set infercase
set smartcase
set hlsearch

"----------Format----------
set expandtab
set shiftwidth=4
set tabstop=4
set autoindent
if has("autocmd")
  filetype on
  autocmd FileType c,cpp,java setlocal cindent
  autocmd FileType c,cpp,java setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2 shiftround
endif

"----------command line----------

" ステータスラインに候補を表示
set wildmenu
" 次のマッチを完全に補完する。wildmenuが有効ならwildmenuを開始
set wildmode=longest,full

set history=100


"----------key map----------

"----------normal mode----------

" 検索候補を画面の中心に表示する
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" 検索の強調表示を無効化し、画面をクリアしてから再描画
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" Y で行全体ではなく、カーソル位置から行末までをコピー(CやDと互換性をもたせる)
nnoremap Y y$

" 貼り付けたテキストの末尾へ自動的に移動
nnoremap <silent> p p`]

" xとsではヤンクしない
nnoremap x "_x
nnoremap s "_s

"----------insert mode----------
inoremap <silent> jj <ESC>
inoremap { {}<LEFT>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap ( ()<LEFT>
inoremap (<Enter> ()<Left><CR><ESC><S-o>
inoremap [ []<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>

" ----------visual mode----------

" <, >キーによるインデント後にviusal modeが解除されないようにする
vnoremap < <gv
vnoremap > >gv

" ヤンクしたテキスト、貼り付けたテキストの末尾に自動的に移動する
vnoremap <silent> y y`]
vnoremap <silent> p p`]

"---------command line----------"
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
" %%でアクティブなバッファのパスを展開
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h') . '/' : '%%'

" 現在のvisual選択範囲を検索する
" c<C-u>call 入力されているすべての文字を削除し、関数を呼び出す
xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>
function! s:VSetSearch()
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" setting instead of tmux

" change the termwinkey to <C-g>
set termwinkey=<C-g>

" ターミナルを開く
" a:1 new or vnew or tabnew(default is new)
" a:2 path (default is current)
" a:3 shell (default is &shell)
function! s:open_terminal(...) abort
	let open_type = 'new'
	let shell = &shell
	let path = getcwd()

	if a:0 > 0 && a:0 !=# ''
		let open_type = a:1
	endif
	if a:0 > 1 && a:2 !=# ''
		let path = a:2
	endif
	if a:0 > 2 && a:3 !=# ''
		let shell = a:3
	endif
	if open_type ==# 'new'
		let open_type = 'bo ' .. open_type
	endif

	execute printf('%s | lcd %s', open_type, path)
	execute printf('term ++curwin ++close %s', shell)
	execute 'call term_setrestore("%", printf("++close bash -c \"cd %s && bash\"", getcwd()))'
endfunction

command! -nargs=* OpenTerminal call s:open_terminal(<f-args>)

" ターミナルを開く
noremap <silent> <C-s>\ :OpenTerminal vnew<CR>
noremap <silent> <C-s>- :OpenTerminal<CR>
noremap <silent> <C-s>^ :OpenTerminal tabnew<CR>
tnoremap <silent> <C-s>\ <C-g>:OpenTerminal vnew<CR>
tnoremap <silent> <C-s>- <C-g>:OpenTerminal<CR>
tnoremap <silent> <C-s>^ <C-g>:OpenTerminal tabnew<CR>

" セッションの保存設定"
set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize,terminal

" タブ移動key map
nnoremap <C-s>n gt
nnoremap <C-s>p gT
tnoremap <C-s>p <C-g>:tabprevious<CR>
tnoremap <C-s>n <C-g>:tabnext<CR>

" ターミナルモードから別ウィンドウへ移動するkey map"
tnoremap <C-g><C-g> <C-g>w

" Undoの永続化
if has('persistent_undo')
  set undodir=~/.vim/undo
  set undofile                                                                                                                                   
endif

" Ctags setting

set tags=.tags;$HOME

" s: はスクリプトローカル変数
function! s:execute_ctags() abort
    " 探すタグファイル名
    let tag_name = '.tags'
    " ディレクトリを遡り、タグファイルを探し、パスを取得
    let tags_path = findfile(tag_name, '.;')
    if tags_path ==# ''
        return
    endif

    " タグファイルのディレクトリパスを取得
    let tags_dirpath = fnamemodify(tags_path, ':p:h')
    " 見つかったタグファイルのディレクトリに移動し、ctagsをバックグラウンドで実行
    execute 'silent !cd' tags_dirpath '&& ctags -R -f' tag_name '2> /dev/null &'
endfunction

augroup ctags
    autocmd!
    autocmd BufWritePost * call s:execute_ctags()
augroup END
