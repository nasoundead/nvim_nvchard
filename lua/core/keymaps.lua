-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Silent keymap option
local opts = { silent = true }

local keymap = vim.keymap

--Remap space as leader key
keymap.set("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- --------插入模式 -----------
keymap.set("i", "jk", "<ESC>")

-- --------视觉模式 -----------
-- 单行或多行移动
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Move text up and down
keymap.set("n", "<A-j>", "<Esc>:m .+1<CR>==gi<esc>", opts)
keymap.set("n", "<A-k>", "<Esc>:m .-2<CR>==gi<esc>", opts)
keymap.set("v", "<A-j>", ":m .+1<CR>==", opts)
keymap.set("v", "<A-k>", ":m .-2<CR>==", opts)

-- Insert --
-- Press jk fast to enter
keymap.set("i", "jk", "<ESC>", opts)
keymap.set("i", "<C-f>", "<right>", opts)  --move cursor right
keymap.set("i", "<C-b>", "<left>", opts)   --move cursor left
keymap.set("i", "<C-a>", "<esc>I", opts)
keymap.set("i", "<C-e>", "<esc>A", opts)

-- Visual --
-- Stay in indent mode
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- j / k 移动太慢， ctrl + u / ctrl + d 默认移动半屏，翻太快，一不留神就不知道翻到哪了
-- 我喜欢把 ctrl + u / ctrl + d 设置成移动 9 行，演示：
keymap.set("n", "<C-u>", "9k", opts)
keymap.set("n", "<C-d>", "9j", opts)

-- Normal --
-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)

-- sv 水平分屏
-- sh 垂直分屏
-- sc 关闭当前分屏 (s = close)
-- so 关闭其他分屏 (o = other)
-- s>s<s=sjsk 分屏比例控制
keymap.set("n", "sv", ":vsp<CR>")
keymap.set("n", "sh", ":sp<CR>")
keymap.set("n", "sc", "<C-w>c")
keymap.set("n", "so", "<C-w>o") -- close others

-- 比例控制（不常用，因为支持鼠标拖拽）
keymap.set("n", "s>", ":vertical resize +20<CR>")
keymap.set("n", "s<", ":vertical resize -20<CR>")
keymap.set("n", "s=", "<C-w>=")
keymap.set("n", "sj", ":resize +10<CR>")
keymap.set("n", "sk", ":resize -10<CR>")

-- Navigate buffers
keymap.set("n", "<S-l>", ":bnext<CR>", opts)
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)


-- Close buffers
keymap.set("n", "<S-q>", "<cmd>Bdelete!<CR>", opts)

-- Save with Ctrl + S
keymap.set("n", "<C-s>", ":w<CR>", opts)

-- Better paste
keymap.set("v", "p", '"_dP', opts)


-- 插件
-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")