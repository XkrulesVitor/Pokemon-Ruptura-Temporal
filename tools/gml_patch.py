"""Utilitarios para editar funcoes GML inteiras por nome (casamento de chaves)."""

import re


def match_brace(text, open_pos):
    depth = 0
    i = open_pos
    in_str = False
    while i < len(text):
        c = text[i]
        if in_str:
            if c == "\\":
                i += 2
                continue
            if c == '"':
                in_str = False
        else:
            if c == '"':
                in_str = True
            elif text.startswith("//", i):
                i = text.index("\n", i)
                continue
            elif text.startswith("/*", i):
                i = text.index("*/", i) + 2
                continue
            elif c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
                if depth == 0:
                    return i
        i += 1
    raise ValueError("chave sem fechamento")


def func_span(text, name):
    m = re.search(r"^function " + re.escape(name) + r"\(", text, re.M)
    if not m:
        raise ValueError("funcao nao encontrada: " + name)
    ob = text.index("{", m.end())
    return m.start(), match_brace(text, ob) + 1


def replace_func(text, name, new_code):
    a, b = func_span(text, name)
    return text[:a] + new_code.strip("\n") + text[b:]


def get_func(text, name):
    a, b = func_span(text, name)
    return text[a:b]


def replace_once(text, old, new):
    n = text.count(old)
    if n != 1:
        raise ValueError("esperava 1 ocorrencia, achei %d: %r" % (n, old[:80]))
    return text.replace(old, new)


def load(path):
    return open(path, "r", encoding="utf-8", newline="").read().replace("\r\n", "\n")


def save(path, text):
    open(path, "w", encoding="utf-8", newline="").write(text)
