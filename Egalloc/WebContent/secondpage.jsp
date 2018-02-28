<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
%>
<%@page
	import="data.Result"
	import="java.util.*"
	import="data.Constants"
	import="java.awt.image.BufferedImage"
%>
<!doctype html>
<html class="no-js" lang="" >
	<head>
		<meta charset="utf-8">
		<meta http-equiv="x-ua-compatible" content="ie=edge" >
		<title></title>
		<meta name="description" content="">
		<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" >
		<link rel="manifest" href="site.webmanifest" >

		<%-- CSS --%>
		<link rel="stylesheet" href="css/main.css" >
		<link rel="stylesheet" href="css/secondpage.css" >

		<%-- JavaScript --%>
		<script src="js/buildcollage.js" type="text/javascript"></script>
		<script type="text/javascript">
			// triggered when user clicks a saved collage
			// gets index of clicked saved collage and saves as sc-id/scID
			// sends sc-id to ServletEngine to update HttpSession variables
			function savedCollageClicked(scID) {
				var xhttp = new XMLHttpRequest();
				xhttp.open("GET", "ServletEngine?sc-id=" + scID, true);
				xhttp.onload = function (e) {
					if (xhttp.readyState === 4) {
						if (xhttp.status === 200) {
							redirectToSecondPage(xhttp.responseText);
						} else {
							console.error("errorr: " + xhttp.responseText);
						}
					}
				};
				xhttp.onerror = function (e) {
					console.error(xhttp.statusText);
				};
				xhttp.send();
			}

			// triggered when user clicks "Export Collage" button
			// exports/saves current collage to user's deafult download directory
			function exportCollage() {
				var img = document.getElementById("collage");
				if (img == null) { return; }
				var fileName = img.name;
				var a = document.createElement('a');
				a.href = img.src;
				a.download = fileName + '.png';
				a.style = 'display: none';
				img.parentNode.appendChild(a);
				a.click();
				a.remove();

				return false;
			}
		</script>
	</head>
	<body>
		<div id="content">
			<div id="collage-generator">
				<div id="collage-container">
					<div
						id="collage-caption"
						class="display-collage centered-width"
					>
						<%
							Result currentResult = (Result) session.getAttribute(Constants.SESSION_CURRENT_RESULT);
							String caption = "";	// if currentResult is failure, no caption
							if (currentResult.isSuccess()) {
								// if currentResult is success, set to "Collage for [keyword]"
								caption = "Collage for " + currentResult.getKeyword();
							}
						%>
						<%=caption%>
					</div>

					<%-- #collage-area holds a collage image or a error message --%>
					<div
						id="collage-area"
						class="collage"
					>
						<%
							if (currentResult.isSuccess()) {
								// if currentResult is success, get image from BufferedImage
								// and display in <img>
								BufferedImage bImage = currentResult.getCollageImage();
								out.print("<img id=\"collage\""
								+ "src=\"data:image/jpg;base64, "
								+ Constants.getImage(bImage)
								+ "\" alt=\"img not found\""
								+ "name=\"" + currentResult.getKeyword() + "\""
								+ "class=\"display-collage collage-area\" />");
							} else {
								// if currentResult is error, get error message
								// and display in <div>
								out.print("<div id=\"collage-placeholder\" class=\"collage-area centered-width\">"
										+ "<div class=\"error-message\">" + currentResult.getErrorMessage() + "</div></div>");
							}
						%>
					</div>
				</div>

				<%-- #search-container holds search text bar,
				"Build Collage" button, and "Export Collage" button --%>
				<div id="search-container">
					<div id="search-bar-container">
						<input
							id="search-bar-input"
							type="text"
							placeholder="Enter topic"
						/>
						<button
							id="search-bar-submit"
							class="search-bar-button"
							type="submit"
							onclick="checkForText()"
						><%=Constants.BUILD_ANOTHER_COLLAGE%></button>
						<button
							id="search-bar-export"
							class="search-bar-button"
							type="submit"
							onclick="exportCollage()"
						><%=Constants.EXPORT_COLLAGE %></button>
					</div>
				</div>
			</div>

			<%-- #saved-collages displays all saved collages, if any exist --%>
			<div id="saved-collages">
				<%
					List<Result> savedCollages = (List<Result>) session.getAttribute("savedCollages");
					if (savedCollages == null || savedCollages.isEmpty()) {
						return;
					}
					for (int i = 0; i < savedCollages.size(); i++) {
						BufferedImage bImage = savedCollages.get(i).getCollageImage();
						out.print("<div id=\"" + i + "\" class=\"saved-collage\" onClick=\"savedCollageClicked(this.id)\"><img src=\"data:image/jpg;base64, " +  Constants.getImage(bImage) + "\"class=\"saved-collage\"/></div>");
					}
				%>
			</div>
		</div>
		
		<%-- JavaScript --%>
		<script src="js/main.js"></script>
	    <script>
				// Implements "Press Enter to trigger 'Build Collage' button functionality"
	    	document.querySelector("#search-bar-input").addEventListener("keyup", event => {
		      if(event.key !== "Enter") return; // Use `.key` instead.
		      document.querySelector("#search-bar-submit").click(); // Things you want to do.
		      event.preventDefault(); // No need to `return false;`.
	  		});
	   	</script>
	</body>
</html>
