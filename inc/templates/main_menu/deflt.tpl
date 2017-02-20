{extends file="layout.tpl"}
{block name=content}
<div id="main">
	<div class="headerrow">
		<span class="header">{#site_title#}</span>
	</div>
	<div>
		 <span id="display_text" style="float:left;">{$smarty.session.display_text}</span>
	</div>
</div>
{/block}