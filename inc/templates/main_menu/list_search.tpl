		<span class="">&nbsp;&nbsp;</span>
		<span class="searchbox">
			<input class="" type="text" id="searchbox" placeholder="search">
			<span class="clear-input" id="searchbox_clear" title="Clear search">×</span>
		</span>

<script type="text/javascript">
	$(document).ready( function () {
		//$("#searchbox").bind("keyup search input paste cut", function(event) {
		$("#searchbox").on("keyup", function(event) {
			if (event.keyCode == 13)
				// Да е с параметър true (по подразбиране), за да опресни и номерата на страниците
				oTable.search(this.value).draw();
		});
		$("#searchbox_clear").on("click", function(event) {
			$("#searchbox").val('');
			oTable.search('').draw();
		});
	}); // $(document).ready
</script>
