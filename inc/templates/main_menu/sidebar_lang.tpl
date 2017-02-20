					{foreach from=$smarty.session.langs item=lang}
					{if $smarty.session.lang.lang == $lang}
						| <strong>{$lang}</strong>
					{else}
						| <a href="" onclick="changeLang('{$lang}')">{$lang}</a>
					{/if}
					{/foreach}
