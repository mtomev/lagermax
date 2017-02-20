{extends file="layout.tpl"}
{block name=content}
<div id="main">
	<div class="headerrow">
		<span class="header">{#language_editor#}</span>
	</div>
	<p>
		{#language_choose#}:
	</p>

	<div class="submenu">
		<ul>
			{foreach from=$smarty.session.langs item=lang}
			<li>
				{if $clang == $lang}{$lang}{else}
				<a href="/main_menu/languages/{$lang}">{$lang}</a></li>
				{/if}
			{/foreach}
		</ul>
	</div>
	
	{if $lang_data}
		<div class="header">{#language_cur_edit#} {$clang}</div>
		<div id="edit">
			<input type="hidden" name="lang" value="{$clang}">
			<textarea id="lang_data" name="lang_data" style="width: 670px; height: 500px;">{$lang_data}</textarea>
		</div>
		<div class="row-button">
			<button class="save_button" id="save_button"><span>{#btn_Save#}</span></button>
			<span>{$clang}</span>
			<button class="cancel_button" id="cancel_button"><span>{#btn_Cancel#}</span></button>
		</div>
	{/if}
	
</div>

<script type="text/javascript">
	$('#save_button').click (function () {
		jQuery.post('/main_menu/languages_save/{$clang}', $('#edit :input').serialize(), function (result) {
			if (result) 
				fnShowErrorMessage('{#title_error#}', result);
			else
				window.location.href = '/main_menu/languages';
		});
	});

	$('#cancel_button').click (function () {
		window.location.href = '/main_menu/languages';
	});
</script>

{/block}