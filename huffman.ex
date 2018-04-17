defmodule Huffman do
  def sample do
   'the quick brown fox jumps over the lazy dog this is a sample text that we will use when we build up a table we will only handle lower case letters and no punctuation symbols the frequency will of course not represent english but it is probably not that far off'
   # 'the essential feature'
  end

  def text, do: 'this is something that we should encode'

  def test do
    sample = sample()
    tree = tree(sample)
    encode = encode_table(tree)
    decode = decode_table(tree)
    text = text()
    seq = encode(text, encode)
    # decode(seq, decode)
    seq

  end

  def read(file, n) do
    {:ok, file} = File.open(file, [:read])
    binary = IO.read(file, n)
    File.close(file)

    case :unicode.characters_to_list(binary, :utf8) do
      {:incomplete, list, _} -> list;
      list -> list
    end
  end

  def tree(sample) do
    frequency = freq(sample)
    huffman(frequency)
  end

  # encode_table(tree)
  def encode_table(tree) do
    [head|_] = tree
    tree = elem(head,0)
    {left, right} = tree
    result = encode_table(0, left, [], [])
    encode_table(1, right, [], result)
  end
  def encode_table(0, left, path, result) do
    # IO.puts "left Result"
    # IO.inspect left
    path = [0|path]
    # IO.puts "left"
    cond do
      is_number(left)  == true ->
        # IO.inspect left
        # IO.inspect reverse(path)
        # IO.puts "---------------------------------"
        result = [{left, reverse(path)}|result]
      is_tuple(left) == true ->
        {lleft, lright} = left
        # IO.inspect result
        result = encode_table(0, lleft, path, result)
        result = encode_table(1, lright, path, result)
    end
  end
  def encode_table(1, right, path, result) do
    # IO.puts "right Result"
    # IO.inspect right
    path = [1|path]
    # IO.puts "right"
    cond do
      is_number(right)  == true ->
        # IO.inspect right
        # IO.inspect reverse(path)
        # IO.puts "---------------------------------"
        result = [{right, reverse(path)}|result]
      is_tuple(right) == true ->
        {rleft, rright} = right
        # IO.inspect result
        result = encode_table(0, rleft, path, result)
        result = encode_table(1, rright, path, result)
    end
  end
  #   branch = {}
  #   encode_table(tree, branch, [], [])
  # end
  # def encode_table(tree, branch, character, path) do
  #   cond do
  #     is_number(tree) == true || is_number(branch) == true ->
  #         # character = [{to_charlist(<<tree :: utf8>>),path}|character]
  #         character = [{tree,path}|character]
  #
  #     is_tuple(tree) == true || is_tuple(branch) == true ->
  #           branch = elem(tree, 1)
  #           tree = elem(tree, 0)
  #           character = encode_table(branch, {}, character, [1|path])
  #           character = encode_table(tree, {}, character, [0|path])
  #   end
  # end

  # decode_table
  def decode_table(tree) do
    encode_table(tree)
  end

  # encode_table(text,table)
  def encode(text, table) do
    encode(text, table, [])
  end
  def encode([], table, sequence) do
    sequence
  end
  def encode(text, table, sequence) do
    [character|rest] = text
    current = searchEncode(character, table)
    sequence = Enum.concat(sequence, elem(current, 1))
    # sequence = [elem(current,1)|sequence]
    encode(rest, table, sequence)
  end
  def searchEncode(character, [head|tail]) do
    cond do
      character == elem(head,0) -> head
      character != elem(head,0) && tail != []-> searchEncode(character, tail)
    end
  end

  # decode
  def decode([], _, text), do: reverse(text)
  def decode(seq, table) do
    # IO.puts "first decode"
    decode(seq, table, [])
  end
  def decode(seq, table, text) do
    # IO.puts "decode"
    {char, rest} = decode_char(seq, 1, table)
    text = [char | text]
    # IO.puts "char"
    # IO.inspect char
    # IO.puts "rest"
    # IO.inspect rest
    decode(rest, table, text)
  end
  def decode_char(seq, n, table) do
    {code, rest} = Enum.split(seq, n)
    seq = rest
    case List.keyfind(table, code, 1) do
      nil ->
        seq = Enum.concat(code, rest)
        # IO.puts "seq"
        # IO.inspect seq
        decode_char(seq, n+1, table)
      _ ->
      {char, encrypted} = List.keyfind(table, code, 1)
      # IO.inspect encrypted
      {char, rest}
    end
  end

  # freq
  def freq(sample) do
    # sample = sample()
    freq(sample, unique(sample), [])
  end
  def freq(sample, [uchar|urest], freq) do
    freq = [{uchar, count(uchar, sample)}|freq]
    freq(sample, urest, freq)
  end
  def freq(sample,[], freq) do
    orderedSequence(freq)
  end

  # huffman
  def huffman(frequency) do
    lenF = len(frequency)
    case lenF do
      2 -> [left, right|_] = frequency
      tree = [{{elem(left,0),elem(right, 0)}, elem(left,1)+elem(right,1)}]
      _ -> [left, right|tail] = frequency
      tuple = {{elem(left,0), elem(right,0)}, elem(left,1) + elem(right,1)}
      tail = insert(tuple, tail)
      length = len(tail)
      case length do
        2 -> [tleft, tright|_] = tail
        tree = [{{elem(tleft,0),elem(tright, 0)}, elem(tleft,1)+elem(tright,1)}]
        _ -> huffman(tail)
      end
    end
  end

  # def huffman(frequency, finalNumber) do
  #   [left, right|_] = frequency
  #   tupel = {{elem(left,0), elem(right,0)}, (elem(left,1) + elem(right,1))}
  #   # approach 1
  #   frequency = [tupel | frequency]
  #   frequency = orderedSequence(frequency)
  #   if (elem(tupel,1) == finalNumber) do
  #     # orderedSequence(frequency)
  #     IO.puts "finally"
  #   else
  #     huffman(frequency, finalNumber)
  #   end
  #   # approach 2
  #   # frequency = insert(tupel, frequency)
  #   # if (elem(tupel,1) == finalNumber) do
  #   #   frequency
  #   # else
  #   #   huffman(frequency, finalNumber)
  #   # end
  # end

  # sum
   def sum([]) do
       0
   end
   def sum(list) do
       sum(list, 0)
   end
   def sum([], accumulated_sum) do
       accumulated_sum
   end
   def sum([head | tail], accumulated_sum) do
       sum(tail, elem(head,1) + accumulated_sum)
   end

  # orderedSequence
  def orderedSequence(freq) do
    [head|tail] = freq
    list = [head|[]]
    orderedSequence(tail, list)
  end

  def orderedSequence([head|tail], list) do
    list = insert(head, list)
    orderedSequence(tail, list)
  end

  def orderedSequence([], list) do
    list
  end

  # insert
  def insert(element, list) do
     insert(element, list, [])
  end
  def insert(element, [head|tail], inresult) do
     cond do
       elem(element,1) <= elem(head,1) -> inresult = [element|inresult]; element = head
                          if (len([head|tail]) == 1) do
                            inresult = [head|inresult]
                          end
       elem(element,1) > elem(head,1) -> inresult = [head|inresult]
                         if (len([head|tail]) == 1) do
                           inresult = [element|inresult]
                         end
     end
     insert(element, tail, inresult)
   end

   def insert(element, [], inresult) do
     reverse(inresult)
   end

  # unique
   def unique(list) do
     unique(list, [])
   end

   def unique([head|tail], helplistunique) do
     helplistunique = [head|helplistunique]
     tail = remove(head, [head|tail])
     unique(tail, helplistunique)
   end

   def unique([], helplistunique) do
     helplistunique
   end

   def reverse(list) do
     reverse(list,[])
   end

   def reverse([head|tail],helplistreverse) do
     helplistreverse = [head|helplistreverse]
     reverse(tail, helplistreverse)
   end

   def reverse([], helplistreverse) do
     helplistreverse
   end

   # count frequency
   def count(x, list) do
     count(x, list, 0)
   end

   def count(x, [head|tail], number) do
     if(x == head) do
       number = number + 1
     end
     count(x, tail, number)
   end

   def count(x, [], number) do
     number
   end

   # remove
   def remove(x, list) do
     remove(x, list, [])
   end
   def remove(x, [head|tail], helplistremove) do
     if (x !== head) do
       helplistremove = [head|helplistremove]
     end
    remove(x, tail, helplistremove)
   end

   def remove(x, [], helplistremove) do
     helplistremove
   end

   # length
   def len([]) do
       0
   end
   def len(l) do
       len(l,0)
   end
   def len([], length) do
       length
   end
   def len([_|tail], length) do
       len(tail, length + 1)
   end
end
