{extends file="layout.tpl"}
{block name=content}
{if $smarty.session.userdata.grants.sys_reports == '1' && $smarty.session.userdata.user_id == '1'}
<div id="main">
	<div class="row-button">
		<button class="save_button" id="show_session"><span>Session var</span></button>
	</div>

	<div id="session_var" style="float:left;">
		<table class="dataTable cell-border hover" cellpadding="5" cellspacing="0" border="0">
			{foreach $smarty.session as $key=>$item}
				<tr>
					<td>{$key}</td>
					<td>{if $item|@is_array}<pre>{$item|@var_export:true|nl2br2}</pre>{else}{$item}{/if}</td>
				</tr>
			{/foreach}
		</table>
	</div>

</div>
<script type="text/javascript">
	$('#show_session').click (function () {
		window.location.href = '/sys_reports/deflt/reload';
	});
</script>
{/if}
{/block}