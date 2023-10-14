package errhandl

import "log"

func Try(e error) error {
	if e != nil {
		return e
	}
	return nil
}

func Expect(e error) {
	if e != nil {
		log.Fatal(e)
	}
}
