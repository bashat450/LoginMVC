
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CrudMap.Models;

namespace CrudMap.Controllers
{
    public class LoginController : Controller
    {
        string conStr = ConfigurationManager.ConnectionStrings["image"].ConnectionString;

        // GET: Login
        public ActionResult Login()
        {
            var model = new LoginModel();

            if (Request.Cookies["UserEmail"] != null)
            {
                model.EmailId = Request.Cookies["UserEmail"].Value;
            }

            return View(model);
        }

        [HttpPost]
        public ActionResult Login(LoginModel model, string RememberMe)
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT Password FROM Register WHERE EmailId = @EmailId", con);
                cmd.Parameters.AddWithValue("@EmailId", model.EmailId);

                con.Open();
                object result = cmd.ExecuteScalar();

                if (result != null && result is byte[] dbPasswordBytes)
                {
                    byte[] inputHashedBytes = PasswordHelper.HashPasswordAsBytes(model.Password);

                    // 🔍 Debugging output
                    Console.WriteLine("DB Password Bytes: " + BitConverter.ToString(dbPasswordBytes));
                    Console.WriteLine("Input Hashed Bytes: " + BitConverter.ToString(inputHashedBytes));

                    if (dbPasswordBytes.SequenceEqual(inputHashedBytes))
                    {
                        Session["UserEmail"] = model.EmailId;

                        if (!string.IsNullOrEmpty(RememberMe) && RememberMe.ToLower() == "true")
                        {
                            HttpCookie cookie = new HttpCookie("UserEmail");
                            cookie.Value = model.EmailId;
                            cookie.Expires = DateTime.Now.AddDays(7);
                            Response.Cookies.Add(cookie);
                        }

                        return RedirectToAction("Lists", "Teachers");
                    }
                }
            }
            ViewBag.Message = "Invalid Email or Password";
            return View(model);
        }


        public ActionResult Create()
        {
            ViewBag.CountryList = GetCountries();
            return View();
        }

        [HttpPost]
        public ActionResult Create(LoginModel model)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.CountryList = GetCountries();
                return View(model);
            }

            using (SqlConnection con = new SqlConnection(conStr))
            {
                byte[] hashedPasswordBytes = PasswordHelper.HashPasswordAsBytes(model.Password);

                SqlCommand cmd = new SqlCommand("SP_InsertRegisterDetails", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@FullName", model.FullName);
                cmd.Parameters.AddWithValue("@EmailId", model.EmailId);
                cmd.Parameters.AddWithValue("@Password", hashedPasswordBytes); // ✅ VARBINARY
                cmd.Parameters.AddWithValue("@Date", DateTime.Now);
                cmd.Parameters.AddWithValue("@CountryId", model.CountryId);

                con.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    string result = reader[0].ToString();
                    TempData["Message"] = result;
                }
            }

            return RedirectToAction("Login");
        }




        private List<SelectListItem> GetCountries()
        {
            List<SelectListItem> countries = new List<SelectListItem>();
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT CountryId, CountryName FROM Country", con);
                con.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    countries.Add(new SelectListItem
                    {
                        Value = reader["CountryId"].ToString(),
                        Text = reader["CountryName"].ToString()
                    });
                }
            }
            return countries;
        }

        public ActionResult Logout()
        {
            Session.Clear();
            return RedirectToAction("Login");
        }

    }
}
