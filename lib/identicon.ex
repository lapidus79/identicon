defmodule Identicon do
  @moduledoc """
    Generates Identicons
  """

  @doc """
    Generates an Identicon image based on the input string
    given and saves that identicon into a file
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image) 
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250,250)
    fill = :egd.color(color)
    Enum.each pixel_map, fn({start,stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
      ### WTF? Is it mutating the image in place...?
    end
    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} =  image) do
    pixel_map = Enum.map grid, fn({_code, idx}) ->
      x = rem(idx, 5) * 50
      y = div(idx, 5) * 50
      top_left = {x, y}
      bottom_right = { x + 50, y + 50}
      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    filtered_grid = Enum.filter grid, fn({code, _idx}) ->
      rem(code,2) == 0
    end
    %Identicon.Image{image | grid: filtered_grid}
  end

  @doc """
    Generate new Identicon with the grid defined
  """
  def build_grid(%Identicon.Image{hex: hex_list} = image) do
    grid =
      hex_list
      |> Enum.chunk(3)
      |> Enum.map(&mirror_list/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Mirror a list

  ## Examples

    iex> Identicon.mirror_list([1,2,3])
    [1,2,3,2,1]

    iex> Identicon.mirror_list([1,2])
    [1,2,1]

  """
  def mirror_list(list) do
    rev =
      list
      |> Enum.slice(0, length(list) - 1)
      |> Enum.reverse

    list ++ rev # Same as Enum.concat
  end


  @doc """
    Generate a new Identicon with color defined

  ## Examples

      iex> image = Identicon.hash_input('elixir')
      iex> Identicon.pick_color(image)
      %Identicon.Image{color: {116, 181, 101},
      hex: [116, 181, 101, 134, 90, 25, 44,
      200, 105, 60, 83, 13, 72, 235, 56, 58]}

  """
  def pick_color(%Identicon.Image{hex: [r,g,b | _tail ]} = image) do
    %Identicon.Image{image | color: {r,g,b}}
  end

  @doc """
    Hashes the input

  ## Examples

      iex> Identicon.hash_input('Elixir')
      %Identicon.Image{hex: [161, 46, 176, 98, 236, 169, 209, 230, 198, 159, 207, 139, 96, 55, 135, 195]}
  """
  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

end
