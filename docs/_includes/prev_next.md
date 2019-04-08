{% assign all_pages = site.pages | concat: site.docs | where_exp: "item", "item.nav_order" %}
{% assign links = all_pages | sort: "nav_order" %}
{% for link in links %}
	{% if link.url == page.url %}
		{% unless forloop.first %}
			{% assign prev = tmpprev %}
		{% endunless %}
		{% if forloop.last %}
		  {% assign last = "/reference" %}
		{% else %}
			{% assign next = links[forloop.index] %}
		{% endif %}
	{% endif %}
	{% assign tmpprev = link %}
{% endfor %}

{% if prev %}<a id="prev" class="btn btn-basic" href="{{ prev.url }}">Back</a>{% endif %}{% if last %}<a id="next" class="btn btn-primary" href="/reference">Next Step</a>{% endif %}
{% if next %}<a id="next" class="btn btn-primary" href="{{ next.url }}">Next Step</a>{% endif %}
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
