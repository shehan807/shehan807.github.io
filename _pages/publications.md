---
layout: page
permalink: /publications/
title: publications
description: publications by categories in reversed chronological order. generated by jekyll-scholar.
nav: true
nav_order: 2
---

<!-- _pages/publications.md -->

<!-- Bibsearch Feature -->

{% include bib_search.liquid %}

<div class="publications">

<h2 class="bibliography-title" style="color: var(--global-theme-color); font-weight: bold;">Journal Articles</h2>
{% bibliography --query @article --group_by year --group_order descending %}

<h2 class="bibliography-title" style="color: var(--global-theme-color); font-weight: bold; margin-top: 3rem;">Conference Proceedings</h2>
{% bibliography --query @inproceedings --group_by year --group_order descending %}

</div>
