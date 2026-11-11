package libsharing

import "github.com/iherdt/screen-sharing-remote/internal/cursortheme"

func ImportCursorTheme(source string, destination string) error {
	return cursortheme.Import(source, destination)
}
