package main

import (
	"bufio"
	"compress/gzip"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"hash/fnv"
	"log"
	"net/http"
	"os"
	"path"
	"strings"
)

const (
	entries   = 10000
	shaSuffix = ".sha256sum"
)

var stories = map[uint32]string{}

func handler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/" {
		fmt.Fprintf(w, `<html>
	<title>Fake content with sha</title>

	<p>This site generates fake content based deterministically based on the URL.
	It also serves ".sha256sum" files based on that content.</p>

	<p>The content has been generated with <a href="github.com/mb-14/gomarkov">github.com/mb-14/gomarkov</a></p>
	<p>The sources for this tool is available at <a href="http://github.com/mkmik/fakesha">http://github.com/mkmik/fakesha</a></p>
	`)
		return
	}

	ext := path.Ext(r.URL.Path)
	base := strings.TrimSuffix(r.URL.Path, shaSuffix)

	n := hash(base)
	s := stories[n]
	if ext == shaSuffix {
		h := sha256.New()
		fmt.Fprintln(h, s)
		x := hex.NewEncoder(w)
		fmt.Fprintf(x, "%s", h.Sum(nil))
		fmt.Fprintln(w)
	} else {
		fmt.Fprintln(w, s)
	}
}

func hash(s string) uint32 {
	h := fnv.New32a()
	h.Write([]byte(s))
	return h.Sum32() % entries
}

func load() error {
	f, err := os.Open("stories.txt.gz")
	if err != nil {
		return err
	}

	g, err := gzip.NewReader(f)
	if err != nil {
		return err
	}

	scanner := bufio.NewScanner(g)
	for scanner.Scan() {
		s := scanner.Text()
		n := hash(s)
		stories[n] = s
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	return nil
}

func main() {
	if err := load(); err != nil {
		log.Fatal(err)
	}

	http.HandleFunc("/", handler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Listening on port %s\n", port)

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}