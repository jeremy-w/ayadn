#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class View
		def create_content_string(item, annotations, me_mentioned)
			user_name, user_real_name, user_handle = objectNames(item['user'])
			created_day, created_hour = objectDate(item)
			view_params = {
				id: item['id'],
				created_day: created_day,
				created_hour: created_hour,
				user_handle: user_handle,
				user_real_name: user_real_name,
				text: coloredText(item),
				links: objectLinks(item),
				annotations: annotations,
				me_mentioned: me_mentioned,
				num_replies: item['num_replies'],
				reply_to: item['reply_to']
			}
			object_view(view_params)
		end
		def skip_hashtags(item, saved_tags)
			skipped_hashtags_encountered = false
			for post_tag in item['entities']['hashtags'] do
				case post_tag['name']
				when *saved_tags
					skipped_hashtags_encountered = true
			 		next # get out of this loop
				end
			end
			return skipped_hashtags_encountered
		end
		def coloredText(item)
			obj_text = item['text']
			obj_text != nil ? (colored_post = $tools.colorize(obj_text)) : (colored_post = "--Post deleted--".red)
		end
		def objectDate(item)
			created_at = item['created_at']
			return created_at[0...10], created_at[11...19]
		end
		def objectLinks(item)
			links = item['entities']['links']
			links_string = ""
			if !links.empty?
				if item['annotations'] == nil
					links_string << "\n"
				end
				for link in links do
					links_string << "Link: ".cyan + link['url'].brown + "\n"
				end
			end
			return links_string
		end
		def objectSource(item)
			return item['source']['name'], item['source']['link']
		end
		def objectNames(item)
			user_name = item['username']
			user_handle = "@" + user_name
			return user_name, item['name'], user_handle
		end
		def checkins_annotations(item)
			anno_string = ""
			annotations_list = item['annotations']
			xxx = 0
			if annotations_list != nil
				annotations_list.each do
					annotation_type = annotations_list[xxx]['type']
					annotation_value = annotations_list[xxx]['value']
					if annotation_type == "net.app.core.checkin" or annotation_type == "net.app.ohai.location"
						checkins_name = annotation_value['name']
						checkins_address = annotation_value['address']
						checkins_locality = annotation_value['locality']
						checkins_region = annotation_value['region']
						checkins_postcode = annotation_value['postcode']
						checkins_country_code = annotation_value['country_code']
						anno_string << "\n" + ("." * (checkins_name.length + 6)) #longueur du nom plus son étiquette
						anno_string << ("\nName: ".cyan + checkins_name.upcase.reddish) unless checkins_name.nil?
						anno_string << ("\nAddress: ".cyan + checkins_address.green) unless checkins_address.nil?
						anno_string << ("\nLocality: ".cyan + checkins_locality.green) unless checkins_locality.nil?
						anno_string << (" (#{checkins_postcode})".green) unless checkins_postcode.nil?
						anno_string << ("\nState/Region: ".cyan + checkins_region.green) unless checkins_region.nil?
						anno_string << (" (#{checkins_country_code})".upcase.green) unless checkins_country_code.nil?
						unless @source_name.nil? or $tools.config['timeline']['show_client']
							anno_string << "\nPosted with: ".cyan + "#{@source_name} [#{@source_link}]".green + " "
						end
						#anno_string += "\n"
					end
					if annotation_type == "net.app.core.oembed"
						@same_link = false
						photo_link = annotation_value['embeddable_url']
						if photo_link != nil
							item['entities']['links'].each do |link|
								@same_link = true if link['url'] == photo_link
							end
						end
						anno_string << ("\nLink: ".cyan + photo_link.brown) if @same_link == false
					end
					xxx += 1
				end
				return anno_string
			end
		end
		def object_view(params)
			if params[:me_mentioned] == true
				obj_view = "\n" + params[:id].to_s.cyan.reverse_color.ljust(14)
			else
				obj_view = "\n" + params[:id].to_s.cyan.ljust(14)
			end
			obj_view << ' '
			obj_view << params[:user_handle].green
			obj_view << ' '
			obj_view << "[#{params[:user_real_name]}]".magenta
			obj_view << ' '
			obj_view << params[:created_day].cyan + ' ' + params[:created_hour].cyan 
			obj_view << ' '
			obj_view << "[#{@source_name}]".cyan if $tools.config['timeline']['show_client']
			if $tools.config['timeline']['show_symbols']
				obj_view << " <".blue if params[:reply_to] != nil
				obj_view << " >".blue if params[:num_replies] > 0
			end
			obj_view << "\n"
			obj_view << params[:text]
			if params[:annotations] != nil
				obj_view << params[:annotations] + "\n"
			end
			obj_view << params[:links] + "\n"
		end
		def file_view(params)
			file_elements = "\nName: ".cyan + params[:name].green
			file_elements << "\nKind: ".cyan + params[:kind].pink
			file_elements << "\nSize: ".cyan + params[:file_size_converted].reddish unless params[:file_size] == nil
			file_elements << "\nDate: ".cyan + params[:created_day].green + " " + params[:created_hour].green
			file_elements << "\nSource: ".cyan + params[:source_name].brown + " - #{params[:source_link]}".brown
		end
		def filesDetails(item)
			created_day, created_hour = objectDate(item)
			file_size = item['size']
			file_size_converted = file_size.to_filesize unless file_size == nil
			{
				name: item['name'],
				file_token: item['file_token'],
				source_name: item['source']['name'],
				source_link: item['source']['link'],
				kind: item['kind'],
				id: item['id'],
				file_size: file_size,
				file_size_converted: file_size_converted,
				file_is_public: item['public'],
				file_url: item['url_permanent'],
				created_day: created_day,
				created_hour: created_hour
			}
		end
		def derivedFilesDetails(derived_files)
			if derived_files != nil
				if derived_files['image_thumb_960r'] != nil
					#file_derived_bigthumb_name = derived_files['image_thumb_960r']['name']
					file_derived_bigthumb_url = derived_files['image_thumb_960r']['url']
				end
				if derived_files['image_thumb_200s'] != nil
					#file_derived_smallthumb_name = derived_files['image_thumb_200s']['name']
					file_derived_smallthumb_url = derived_files['image_thumb_200s']['url']
				end
				list_string += "\nBig thumbnail: ".cyan + file_derived_bigthumb_url unless file_derived_bigthumb_url == nil
				list_string += "\nSmall thumbnail: ".cyan + file_derived_smallthumb_url unless file_derived_smallthumb_url == nil
			end
			return list_string
		end
	end
end